

import java.net.*;
import java.io.*;


class Client
{
    public static void main(String args[]) throws Exception
    {
        Socket soc=new Socket("127.0.0.1",5217);
        transferfileClient t=new transferfileClient(soc);
        t.displayMenu();
        
    }
}
class transferfileClient
{
    Socket ClientSoc = null;
    
    DataInputStream din = null;
    DataOutputStream dout = null;
    BufferedReader br = null;
    
    Socket TransferSoc = null;
    
    DataInputStream tdin = null;
    DataOutputStream tdout = null;
     
    String username = null;
    boolean logged = false;
    transferfileClient(Socket soc)
    {
        try
        {
            ClientSoc=soc;
            din=new DataInputStream(ClientSoc.getInputStream());
            dout=new DataOutputStream(ClientSoc.getOutputStream());
            br=new BufferedReader(new InputStreamReader(System.in));
        }
        catch(IOException ex)
        {
        	System.out.println(ex);
        }        
    }
    void login() {
		try {
			String pass, reply;
			System.out.println(din.readUTF());
			username = br.readLine();
			dout.writeUTF(username);
			reply = din.readUTF();
			if (!reply.equals("OK")) {
				System.out.println(reply);
				logged = false;
				return;
			}
			System.out.println(din.readUTF());
			pass = br.readLine();
			dout.writeUTF(pass);
			reply = din.readUTF();
			if (!reply.equals("OK")) {
				System.out.println(reply);
				logged = false;
				return;
			}
			logged = true;
		}catch(IOException i) {
			System.out.println(i);
		}
	}
	void logout() {
		username = null;
		logged = false;
	}
    void SendFile() throws Exception
    {        
        TransferSoc = new Socket("127.0.0.1",5218);
        tdin = new DataInputStream(TransferSoc.getInputStream());
        tdout = new DataOutputStream(TransferSoc.getOutputStream());
        
        String filename;
        System.out.print("Enter File Name :");
        filename=br.readLine();
            
        File f=new File(filename);
        if(!f.exists())
        {
            System.out.println("File not Exists...");
            dout.writeUTF("File not found");
            return;
        }
        
        tdout.writeUTF(filename);
        
        String type;
        do {
	        System.out.print("Enter file type(movies/music/docs):");
	        type = br.readLine();
        }while(!type.equals("movies") && !type.equals("music") && !type.equals("docs"));
        tdout.writeUTF(type);
        
        String msgFromServer=tdin.readUTF();
        if(msgFromServer.compareTo("File Already Exists")==0)
        {
            String Option;
            System.out.println("File Already Exists. Want to OverWrite (Y/N) ?");
            Option=br.readLine();            
            if("Y".equals(Option))    
            {
                tdout.writeUTF("Y");
            }
            else
            {
                tdout.writeUTF("N");
                return;
            }
        }
        
        
        System.out.println("Sending File ...");
        try (FileInputStream fin = new FileInputStream(f)) {
            int ch;
            do
            {
                ch=fin.read();
                tdout.writeUTF(String.valueOf(ch));
            }
            while(ch!=-1);
        }
        System.out.println(tdin.readUTF());
        tdin.close();
        tdout.close();
        TransferSoc.close();
    }
    
    void ReceiveFile() throws Exception
    {
    	TransferSoc = new Socket("127.0.0.1",5218);
        tdin = new DataInputStream(TransferSoc.getInputStream());
        tdout = new DataOutputStream(TransferSoc.getOutputStream());
        
        String fileName;
        System.out.print("Enter File Name :");
        fileName=br.readLine();
        tdout.writeUTF(fileName);
        String msgFromServer=tdin.readUTF();
        
        if(msgFromServer.compareTo("File Not Found")==0)
        {
            System.out.println("File not found on Server ...");
        }
        else if(msgFromServer.compareTo("READY")==0)
        {
            System.out.println("Receiving File ...");
            File f=new File(fileName);
            if(f.exists())
            {
                String Option;
                System.out.println("File Already Exists. Want to OverWrite (Y/N) ?");
                Option=br.readLine();            
                if("N".equals(Option))    
                {
                    tdout.flush();
                    return;    
                }                
            }
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
            System.out.println(tdin.readUTF());
                
        }
        
        tdin.close();
        tdout.close();
        TransferSoc.close();
    }
    
    void showDir() {
    	try {
    		for (int i = 0; i < 3; ++i) {
    			System.out.println(din.readUTF());
    			String str = din.readUTF();
    			while(!str.equals("END")) {
    				System.out.println(str);
    				str = din.readUTF();
    			}
    		}
    	}
    	catch(IOException e) {
    		System.out.println(e);
    	}
    }
    public void displayMenu() throws Exception
    { 
        while(true)
        {    
        	if(!logged) {
        		login();
        		continue;
        	}
            System.out.println("[ MENU ]");
            System.out.println("1. Send File");
            System.out.println("2. Receive File");
            System.out.println("3. Show my directories");
            System.out.println("4. Logout");
            System.out.println("5. Exit");
            System.out.print("\nEnter Choice :");
            int choice; String str;
            do {
            	str = br.readLine();
            } while(str.equals(""));
            choice=Integer.parseInt(str);
            switch (choice) {
                case 1:
                    dout.writeUTF("SEND");
                    SendFile();
                    break;
                case 2:
                    dout.writeUTF("GET");
                    ReceiveFile();
                    break;
                case 3:
                	dout.writeUTF("SHOW");
                	showDir();
                	break;
                case 4:
                    dout.writeUTF("LOGOUT");
                    logout();
                    break;
                default:
                    dout.writeUTF("DISCONNECT");
                    din.close();
                    dout.close();
                    ClientSoc.close();
                    System.exit(1);
            }
        }
    }
}