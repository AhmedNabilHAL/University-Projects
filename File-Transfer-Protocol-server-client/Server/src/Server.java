import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.io.*;
import java.net.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Server
{
    
	@SuppressWarnings("resource")
	public static void main(String args[])
    {
		Hashtable<String, String> password = new Hashtable<String, String>();
        try {
        	File file = new File("user_info.txt"); 
        	  
        	  BufferedReader br = new BufferedReader(new FileReader(file)); 
        	  
        	  String p, u; 
        	  while ((u = br.readLine()) != null) {
        		  p = br.readLine();
        		  if (password.containsKey(u) == false) 
        			  password.put(u, p);
        	  }
	        
	        ServerSocket ss=new ServerSocket(5217);
	        System.out.println("FTP Server Started on Port Number 5217");
        
			while(true)
	        {
	        	Socket soc = null;
	        	try {
		            System.out.println("Waiting for Connection ...");
		            soc = ss.accept();
		            
		            transferfile t=new transferfile(soc, password);
		            t.start();
	        	}
	        	catch(Exception e) {
	        		soc.close();
	        		e.printStackTrace();
	        	}
	            
	        }
        }
	    catch(IOException e) {
	    	System.out.println(e);
	    }
    }
}

class transferfile extends Thread
{
    Socket ClientSoc = null;
    
    DataInputStream din = null;
    DataOutputStream dout = null;
    
    ServerSocket TransferServerSocket = null;
    Socket TransferSoc = null;
    
    DataInputStream tdin = null;
    DataOutputStream tdout = null;
    
    String username = null;
	Hashtable<String, String> password = null;
	boolean logged = false;
	transferfile(Socket soc, Hashtable<String, String> password)
    {
        try
        {
            ClientSoc=soc;     
            TransferServerSocket=new ServerSocket(5218);
            din=new DataInputStream(ClientSoc.getInputStream());
            dout=new DataOutputStream(ClientSoc.getOutputStream());
            this.password = password;
            System.out.println("FTP Client Connected ...");
            
        }
        catch(IOException ex)
        {
        	System.out.println(ex);
        }        
    }
	void setupFiles(){
		
		File dir = new File(username + File.separator + "movies");
		dir.mkdirs();

		dir = new File(username + File.separator + "music");
		dir.mkdirs();

		dir = new File(username + File.separator + "docs");
		dir.mkdirs();
		
	}
	void login() {
		try {
			dout.writeUTF("Please enter username:");
			username = din.readUTF();
			if (!password.containsKey(username)) {
				logged = false; username = null;
				dout.writeUTF("Username not found!");
				return;
			}
			dout.writeUTF("OK");
			dout.writeUTF("Please enter password:");
			String pass = din.readUTF();
			if (!password.get(username).equals(pass)) {
				logged = false; username = null;
				dout.writeUTF("Incorrect password!");
				return;
			}
			logged = true; 
			dout.writeUTF("OK");
			setupFiles();
			
		}catch(IOException i) {
			System.out.println(i);
		}
	}
	void logout() {
		username = null;
		logged = false;
	}
    void SendFile()
    {      
    	try {
	    	TransferSoc = TransferServerSocket.accept();
	        tdin = new DataInputStream(TransferSoc.getInputStream());
	        tdout = new DataOutputStream(TransferSoc.getOutputStream());
	        
	        String filename=tdin.readUTF();
	        String path1 = username + File.separator + "movies", path2 = username + File.separator + "music", path3 = username + File.separator + "docs";
	        File f1=new File(path1 + File.separator + filename), f2=new File(path2 + File.separator + filename), f3=new File(path3 + File.separator + filename);
	        File f = f1;
	        if (f1.exists() && !f1.isDirectory()) {
	        	f = f1;
	        }
	        else if (f2.exists() && !f2.isDirectory()) {
	        	f = f2;
	        }
	        else if (f3.exists() && !f3.isDirectory()) {
	        	f = f3;
	        }
	        
	        if(!f.exists() || f.isDirectory())
	        {
	            tdout.writeUTF("File Not Found");
	        }
	        else
	        {
	            tdout.writeUTF("READY");
	            try (FileInputStream fin = new FileInputStream(f)) {
	                int ch;
	                do
	                {
	                    ch=fin.read();
	                    tdout.writeUTF(String.valueOf(ch));
	                }
	                while(ch!=-1);
	            }
	            tdout.writeUTF("File Receive Successfully");                            
	        }
	        tdin.close();
	        tdout.close();
	        TransferSoc.close();
    	}
    	catch(IOException i) {
    		System.out.println(i);
    	}
    }
    
    void ReceiveFile()
    {
    	try {
	    	TransferSoc = TransferServerSocket.accept();
	        tdin = new DataInputStream(TransferSoc.getInputStream());
	        tdout = new DataOutputStream(TransferSoc.getOutputStream());
	        
	        String filename=tdin.readUTF();
	        if(filename.compareTo("File not found")==0)
	        {
	            return;
	        }
	        String type = tdin.readUTF();
	        File f=new File(username + File.separator + type + File.separator + filename);
	        String option;
	        
	        if(f.exists())
	        {
	            tdout.writeUTF("File Already Exists");
	            option=tdin.readUTF();
	        }
	        else
	        {
	            tdout.writeUTF("SendFile");
	            option="Y";
	        }
	            
            if(option.compareTo("Y")==0)
            {
            	
            	try (FileOutputStream fout = new FileOutputStream(f)) {
                	int ch;
                	String temp;
                	do
                	{
                    	temp=tdin.readUTF();
                    	ch=Integer.parseInt(temp);
                    	if(ch!=-1)
                    	{
                        	fout.write(ch);                    
                    	}
                	}while(ch!=-1);
            	}
                tdout.writeUTF("File Send Successfully");
            }
            tdin.close();
            tdout.close();
            TransferSoc.close();
    	}
        catch(IOException i) {
        	System.out.println(i);
        }
    }
    void showDir() {
    	try {
    		String[] dirs = new String[] {"movies", "music", "docs"};
    		for(String dir : dirs) {
    			dout.writeUTF(dir);
	    		Stream<Path> walk = Files.walk(Paths.get(username + File.separator + dir));
	
	    		List<String> result = walk.filter(Files::isRegularFile).map(x -> x.toString()).collect(Collectors.toList());
	
	    		for (String str : result) {
	    			dout.writeUTF("\t" + str);
	    		}
	    		dout.writeUTF("END");
	    		walk.close();
    		}
    		
    	}
    	catch(IOException e) {
    		System.out.println(e);
    	}
    }

    @Override
    public void run()
    { 
        while(true)
        {
            try
            {
            	if (!logged) {
	            	System.out.println("\tLoggin required ...");
	            	login();
	            	continue;
	            }
            	
	            System.out.println("Waiting for Command ...");
	            String Command=din.readUTF();
	            
	            if(Command.compareTo("GET")==0)
	            {
	                System.out.println("\tGET Command Received ...");
	                SendFile();
	            }
	            else if(Command.compareTo("SEND")==0)
	            {
	                System.out.println("\tSEND Command Receiced ...");                
	                ReceiveFile();
	            }
	            else if(Command.compareTo("SHOW") == 0) {
	            	System.out.println("\tSending Dirs ...");
	            	showDir();
	            }
	            else if(Command.compareTo("LOGOUT") == 0) {
	            	System.out.println("\tSigning out ...");
	            	logout();
	            }
	            else if(Command.compareTo("DISCONNECT")==0)
	            {
	                System.out.println("\tDisconnect Command Received ...");
	                din.close();
	                dout.close();
	                ClientSoc.close();
	                TransferServerSocket.close();
	                return;
	            }
	            
            }
            catch(Exception ex)
            {
            	System.out.println(ex);
            }
        }
    }
}