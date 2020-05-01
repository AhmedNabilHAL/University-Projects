// Problem 2: Online Pizza Reservation
/*

Name: Ahmed Nabil Mohamed Salah El Deeb
ID: 20180413
Group: G14

=========================================================================================================================

Name: Amr Ahmed Ahmed Mohammed
ID: 20180185
Group: G13

*/
/***********************************************************************************************************************/

#include <iostream>


using namespace std;


/***********************************************************************************************************************/
const int LEN = 100;
const int CLEN = 21;
// cities is a list of popular egypt cities
char CITIES[23][21] = { "cairo\0", "alexandria\0", "giza\0", "shubra el kheima\0", "port said\0", "suez\0", "tanta\0",
"asyut\0", "ismailia\0", "fayyum\0", "zagazig\0", "aswan\0", "damietta\0", "al minya\0", "beni suef\0", "qena\0", "sohag\0", "hurghada\0", "6th of october city\0", "shibin el kom\0", "banha\0", "kafr el sheikh\0", "desouk\0" };

// User intep. users diff info
struct user {
	char name[LEN];
	char address[LEN];
	int money = 0;
};

/***********************************************************************************************************************/

// shows main screen options
void showOptions();

// ListOfUsers iterator -> void
// updates users info
void updateInfo(user lou[], int n);

// User -> void
// updates users info
void updateUserInfo(user &u, int n);

// gets a name from the user
void inputName(char name[], int n);

// gets an address from user
void inputAddress(char address[]);

// checks if address is valid
bool isValid(char addr[]);

// takes transactoins from user then calculates money and returns it
int inputTransactions(char name[], bool first);

// ListOfUsers iterator -> void
// prints info all users
void getListInfo(user lou[], int n);

// void -> void
// prints all users' info
void getInfo(user lou[]);

// ListOfUsers Name -> int
// searches for a user and returns user index or -1 if not found
int findUser(user lou[], char name[]);


// String -> String
// turns any string to all lower case
void stringToLower(char str[]);

// extracts city name from given address
void getCity(char addr[], char city[]);

// gets the length of a string
int size(char* str);

// String String int int -> Bool
// compares between two strings given their lenghts true if equal false if not
bool strcompare(char n1[], char n2[]);

// changes a string to an int
int stringToInt(char num[], int j);

// accounts is a global var that keeps count total number of accounts present
int accounts = 0;


/***********************************************************************************************************************/


int main()
{
	user lou[20];
	updateInfo(lou, 0);
	getInfo(lou);

	bool invalid = false;
	bool exit = false;
	char choice;
	do
	{
		showOptions();
		invalid = false;
		
		cin >> choice;
		cin.ignore();
		char name[LEN];
		user u;
		char city[21];
		char c[21];
		int ln = 0;
		int n;
		switch (choice)
		{
		case '1':
		{
				getInfo(lou);
				break;
		}
		case '2':
		{
				cout << "Please enter name of customer you want to view\n\n";
				cin.getline(name, LEN);
				stringToLower(name);
				n = findUser(lou, name);
				if (n == -1)
				{
					cout << "user not found!\n"; break;
				}
				cout << "***************************\n";
				cout << "Balance: " << lou[n].money << endl;
				cout << "***************************\n\n";
				break;
		}
		case '3':
		{
				cout << "Please enter name of customer you want to edit\n\n";
				cin.getline(name, LEN);
				stringToLower(name);
				int money = inputTransactions(name, true);
				n = findUser(lou, name);
				if (n == -1)
				{
					cout << "user not found!\n"; break;
				}
				lou[n].money = money;
				break;

		}
		case '4':
		{
				u = lou[0];
				int max = u.money;

				for (int i = 1; i < accounts; i++)
				{
					if (lou[i].money > max)
					{
						u = lou[i];
						max = u.money;
					}
				}
				cout << "***************************\n";
				cout << "customer with highest balance\n";
				cout << "name: " << u.name << endl;
				cout << "address: " << u.address << endl;
				cout << "Balance: " << u.money << endl;
				cout << "***************************\n\n";
				break;
		}
		case '5':
		{
				cout << "Please enter name of customer you want to edit\n\n";
				cin.getline(name, LEN);
				stringToLower(name);
				cout << "1- To change customers name\n2- To change customers address\n3- To change customers transactions\n\n";
				cin >> choice;
				cin.ignore();
				n = findUser(lou, name);
				if (n == -1)
				{
					cout << "user not found!\n"; break;
				}
				int money = 0;
				switch (choice)
				{
				case '1':
					inputName(lou[n].name, n); break;
				case '2':
					inputAddress(lou[n].address); break;
				case '3':
					money = inputTransactions(name, true);
					lou[n].money = money;
					break;
				}
				break;
		}
		case '6':
		{
				cout << "Please enter city name: \n\n";
				cin.getline(city, CLEN);
				stringToLower(city);
				int counter = 0;

				for (int i = 0; i < accounts; i++)
				{
					getCity(lou[i].address, c);
					if (strcompare(c, city))
						counter++;
				}

				cout << "There are " << counter << " customers in the city of " << city << endl << endl;
				break;
		}
		case '7':
		{
					exit = true;
					break;
		}
		default:
			cout << "Invalid choice!\n\n";
			invalid = true;
		}

	} while (invalid || !exit);

	return 0;
}

/***********************************************************************************************************************/

// ListOfUsers name address money -> void
// updates users info
void updateInfo(user lou[], int n)
{
	accounts++;
	updateUserInfo(lou[n], n);
	char flag = 'n';
	cout << "do you wish to continue? (y/n): ";
	cin >> flag;
	cin.ignore();
	if (n == 20 || flag == 'n')
	{
		return;
	}
	
	updateInfo(lou, n + 1);
}

/***********************************************************************************************************************/

// updates user info
void updateUserInfo(user &u, int n)
{
	inputName(u.name, n);
	inputAddress(u.address);
	int money = inputTransactions(u.name, true);
	u.money = money;
}

/***********************************************************************************************************************/

// gets a name from the user
void inputName(char name[], int n)
{
	cout << "Please enter name of customer number " << n + 1 << endl;
	cin.getline(name, LEN);
	stringToLower(name);
	return;
}

/***********************************************************************************************************************/

// gets an address from user
void inputAddress(char address[])
{
	cout << "Please enter address\n";
	cin.getline(address, LEN);
	stringToLower(address);
	while (!isValid(address))
	{
		cout << "Invalid format. Please enter address\n";
		cin.getline(address, LEN);
		stringToLower(address);
	}
	return;
}

/***********************************************************************************************************************/

// checks if address is valid
bool isValid(char addr[])
{
	int commas = 0;
	bool notdigit = false;
	if (!isdigit(addr[0]))
		return false;
	int i = 1;
	while (addr[i] != '\0')
	{
		if (!isdigit(addr[i]))
			notdigit = true;
		if (isdigit(addr[i]) && notdigit)
			return false;
		if (addr[i] == ',')
		{
			commas++;
			if (commas > 2)
				return false;
		}
		i++;
	}
	if (commas < 2)
		return false;
	char c[CLEN];
	getCity(addr, c);
	if (c[0] == '\0')
		return false;
	for (int i = 0; i < 23; i++)
		if (strcompare(c, CITIES[i]))
			return true;
	return false;
}

/***********************************************************************************************************************/

// takes transactoins from user then calculates money and returns it
int inputTransactions(char name[], bool first)
{
	if (first)
		cout << "Please enter " << name << "'s account transactions\n";
	else
		cout << "Please enter valid transaction:\n";
	int money = 0;
	char tran[LEN];
	cin.getline(tran, LEN);
	stringToLower(tran);
	char op = '-';
	char num[LEN];
	bool invalid = false;
	int ln = size(tran);
	int j = 0;
	for (int i = 0; i < ln; i++)
	{
		
		// if op '-' and tran[i] 'd' or 'w' then set op to 'd' or 'w'
		if (op == '-' && (tran[i] == 'd' || tran[i] == 'w'))
		{
			op = tran[i];
		}
		// else if op 'd' or 'w' and tran[i] is digit then start appending to string num
		else if ((op == 'd' || op == 'w') && isdigit(tran[i]))
		{
			num[j] = tran[i];
			j++;
		}
		// else set invalid? to true
		else if (tran[i] != ' ')
		{
			invalid = true;
			break;
		}
		// if space then add num , set it to "0", set op to '-' and skip
		if (tran[i] == ' ' || i >= ln - 1)
		{
			
			int m = stringToInt(num, j);
			j = 0;
			if (m < 0)
			{
				invalid = true;
				op = '-';
				continue;
			}
			if (op == 'd')
				money += m;
			else
				money -= m;
			if (isdigit(tran[i-1]))
			{

				op = '-';
			}
			continue;
		}
	}
	if (invalid)
		money += inputTransactions(name, false);

		
	
	return money;
}

/***********************************************************************************************************************/

// String -> String
// turns any string to all lower case
void stringToLower(char str[])
{
	int i = 0;
	while (str[i] != '\0')
	{
		str[i] = tolower(str[i]);
		i++;
	}
	return;
}

/***********************************************************************************************************************/

// shows main screen options
void showOptions()
{

	cout << "Hello in bank management system please enter your choice\n";
	cout << "1) To print all names and account balances\n";
	cout << "2) To print specific customer's account balance\n";
	cout << "3) To edit customer transactions\n";
	cout << "4) To show customer with highest balance\n";
	cout << "5) To change customer's name, transactions, balance, or address\n";
	cout << "6) To show how many customers in one city\n";
	cout << "7) To exit program\n\n";
}

/***********************************************************************************************************************/

// extracts city name from given address
void getCity(char addr[], char city[])
{
	int commas = 0;
	int i = 0;
	int j = 0;
	while (addr[i] != '\0')
	{
		if (addr[i] == ',')
			commas++;
		else if (commas >= 2 && addr[i] != ' ')
		{
			city[j] = addr[i];
			j++;
		}
		i++;
	}
	city[j] = '\0';
	return;
}

int size(char* str)
{
	int i = 0;
	while (str[i] != '\0')
		i++;
	return i;
}

void getInfo(user lou[])
{
	for (int i = 0; i < accounts; i++)
	{
		cout << "***************************\n";
		cout << "name: " << lou[i].name << endl;
		cout << "address: " << lou[i].address << endl;
		cout << "money: " << lou[i].money << endl;
		cout << "***************************\n";
	}
	cout << endl;
}

int findUser(user lou[], char name[])
{
	for (int i = 0; i < accounts; i++)
	{
		if (strcompare(lou[i].name, name))
			return i;
	}
	return -1;
}

bool strcompare(char n1[], char n2[])
{
	int ln1 = size(n1);
	int ln2 = size(n2);
	if (ln1 != ln2)
		return false;
	int i = 0;
	while (i < ln1)
	{
		if (n1[i] != n2[i])
			return false;
		i++;
	}
	return true;
}

int stringToInt(char num[], int j)
{
	int val = 0;
	int factor = 1;
	for (int i = j - 1; i >= 0; i--)
	{
		val += (((int)num[i] - '0') * factor);
		factor *= 10;
	}
	return val;
}