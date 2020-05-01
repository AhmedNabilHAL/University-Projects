/**********************************************************************************************************************************
Name: Ahmed Nabil Mohamed Salah El Deeb
ID: 20180413
Group: 10
======================================================
Name: Mahmoud Saad Ahmed Hafez
ID: 20180253
Group: 9
**********************************************************************************************************************************/


#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include <utility>
#include <iomanip>
#include <fstream>
#include <algorithm>
#include <limits>
using namespace std;

// Constants:
// ==============================================================================================================================================================================
const int QPQ = 10, MCQPQ = 2, TFQPQ = 3, CQPQ = 1; // question/quiz
const int FULL_MARK = 10, MCQ_MARK = 2, TFQ_MARK = 1, CQ_MARK = 3; // marks/question
const int CHOICES = 4; // no. of choices/question
const int ADMIN_MENU = 1, VIEW_Q = 1, ADD_Q = 2, LOAD_Q = 3, BACK = 4, UPDATE_NAME = 2, NEW_QUIZ = 3, STATS = 4, SCORES = 5, EXIT = 6;
// ==============================================================================================================================================================================
// picks a random number in range {st, st + 1, ..., end - 1} that's not visited (i.e vis[rand] != 1)
int pick_rand(int st, int en, bool* vis = NULL){
	bool isnull = 0;
	if (!vis) {
		vis = new bool[en]; memset(vis, 0, sizeof vis); isnull = 1;
	}
	int rand_no;
	do{
		rand_no = (rand() + st) % en;
	} while (vis[rand_no]);
	if (isnull) delete[] vis;
	return rand_no;

}
void input(int &n, int l, int r){
	while (!(cin >> n) || n < l || n > r){
		cout << "Invalid input!\n";
		cin.clear();
		cin.ignore(numeric_limits<streamsize>::max(), '\n');
	}
	cin.ignore();
}
// ================================================================================================================================

// ================================================================================================================================
class Question{
protected:
	string text;
	string answer;
	int id;
	static int count;
	string player_answer;
	bool inquiz;
public:
	Question(){}
	Question(const string& text, const string& answer){
		this->text = text, this->answer = answer;
		this->player_answer = "";
		this->inquiz = 0;
		this->id = ++(this->count);
	}
	void setInQuiz(bool inquiz){
		this->inquiz = inquiz;
	}
	int getCount() const{
		return count;
	}
	string getText() const{
		return text;
	}
	string getAnswer() const{
		return answer;
	}
	int getId() const{
		return id;
	}
	string getPlayerAnswer() const{
		return player_answer;
	}
	friend ostream& operator<<(ostream& out, const Question& q){
		if (!q.inquiz) out << "(ID: " << q.id << ") ";
		out << q.text;
		if (!q.inquiz) out << "  (Answer: " << q.answer << ")";
		cout << endl;
		return out;
	}
};
int Question::count;

// ================================================================================================================================
class MCQuestion : public Question{
	string* choices = NULL;

public:
	MCQuestion(){
		this->text = "";
		this->answer = "";
		this->id = -1;
		this->inquiz = 0;
		this->player_answer = "";
		choices = NULL;
	}
	MCQuestion(string& text, string choices[]) : Question(text, answer){
		this->choices = new string[CHOICES];
		this->answer = choices[0];
		for (int i = 0; i < CHOICES; ++i)
			this->choices[i] = choices[i];
	}
	MCQuestion(const MCQuestion& q){
		this->text = q.text;
		this->answer = q.answer;
		this->id = q.id;
		this->inquiz = q.inquiz;
		this->player_answer = q.player_answer;
		delete[] this->choices;
		this->choices = new string[CHOICES];
		for (int i = 0; i < CHOICES; ++i)
			this->choices[i] = q.choices[i];
	}
	void operator=(const MCQuestion& q){
		this->text = q.text;
		this->answer = q.answer;
		this->id = q.id;
		this->inquiz = q.inquiz;
		this->player_answer = q.player_answer;
		delete[] choices;
		this->choices = new string[CHOICES];
		for (int i = 0; i < CHOICES; ++i)
			this->choices[i] = q.choices[i];
	}
	MCQuestion(vector<string>& los, int i){

		if (los.size() <= i) { id = -1; return; }
		text = los[i++];
		if (los.size() <= i) { id = -1; return; }
		answer = los[i];
		this->id = ++count;
		this->choices = new string[CHOICES];

		for (int j = i; j - i < CHOICES; ++j){
			if (los.size() <= j) { id = -1; return; }
			this->choices[j - i] = los[j];
		}
	}
	void shuffleChoices(){
		string* temp = new string[CHOICES];
		bool vis[CHOICES]; memset(vis, 0, sizeof vis);
		int all_vis = 0;
		int rand_no;
		while (all_vis != CHOICES){
			rand_no = pick_rand(0, CHOICES, vis);
			temp[all_vis++] = choices[rand_no];
			vis[rand_no] = 1;
		}
		for (int i = 0; i < CHOICES; ++i)
			this->choices[i] = temp[i];

		delete[] temp;
	}
	friend ostream& operator<<(ostream& out, MCQuestion& q){
		if (!q.inquiz) out << "(ID: " << q.id << ") ";
		out << q.text << endl;
		q.shuffleChoices();
		for (int i = 0; i < CHOICES; ++i)
			out << "          " << '[' << (char)('a' + i) << "] " << q.choices[i] << (q.inquiz ? "" : (q.choices[i] == q.answer ? "*" : ""));
		out << endl;
		return out;
	}
	bool inputPlayerAnswer(){
		cin >> this->player_answer;
		while (this->player_answer != "a" && this->player_answer != "b" && this->player_answer != "c" && this->player_answer != "d"){
			cout << "Error! Please enter a choice(a/b/c/d).\n";
			cin >> this->player_answer;
		}
		this->player_answer = this->choices[this->player_answer[0] - 'a'];
		if (this->player_answer == this->answer)
			return 1;
		return 0;
	}

	friend istream& operator>>(istream& in, MCQuestion& q){
		cout << "\nEnter MCQ question text:\n\n";
		do{
			getline(in, q.text);
		} while (q.text.empty());
		cout << "\nEnter choices:\n\n";
		delete[] q.choices;
		q.choices = new string[CHOICES];
		getline(in, q.choices[0]); q.answer = q.choices[0];
		for (int i = 1; i < CHOICES; ++i)
			getline(in, q.choices[i]);
		q.id = ++(q.count);
		q.inquiz = 0;

		return in;
	}
	~MCQuestion(){

		delete[] this->choices;
	}
};

// ================================================================================================================================
class TFQuestion : public Question{

public:
	TFQuestion(){
		this->text = "";
		this->answer = "";
		this->id = -1;
		this->inquiz = 0;
		this->player_answer = "";
	}
	TFQuestion(string& text, string& answer) : Question(text, answer){}
	TFQuestion(const TFQuestion& q){
		this->text = q.text;
		this->answer = q.answer;
		this->id = q.id;
		this->inquiz = q.inquiz;
		this->player_answer = q.player_answer;
	}
	void operator=(const TFQuestion& q){
		this->text = q.text;
		this->answer = q.answer;
		this->id = q.id;
		this->inquiz = q.inquiz;
		this->player_answer = q.player_answer;
	}
	TFQuestion(vector<string>& los, int i){

		if (los.size() <= i) { id = -1; return; }
		text = los[i++];
		if (los.size() <= i) { id = -1; return; }
		answer = los[i][0] - 32;
		this->id = ++count;
	}

	bool inputPlayerAnswer(){
		cin >> this->player_answer;
		while (this->player_answer != "T" && this->player_answer != "F"){
			cout << "Error! Please enter (T/F).\n";
			cin >> this->player_answer;
		}
		if (this->player_answer == this->answer)
			return 1;
		return 0;
	}

	friend istream& operator>>(istream& in, TFQuestion& q){
		cout << "\nEnter TF question text:\n\n";
		do{
			getline(in, q.text);
		} while (q.text.empty());
		cout << "\nEnter correct answer:(T/F)\n\n";
		do{
			getline(in, q.answer);
		} while (q.answer.empty());
		while (q.answer != "T" && q.answer != "F"){
			cout << "Error! Please enter (T/F).\n";
			in >> q.answer;
		}
		q.id = ++(q.count);
		q.inquiz = 0;

		return in;
	}
};

// ================================================================================================================================
class CQuestion : public Question{
public:
	CQuestion(){
		this->text = "";
		this->answer = "";
		this->id = -1;
		this->inquiz = 0;
		this->player_answer = "";
	}
	CQuestion(string& text, string& answer) : Question(text, answer){}
	CQuestion(const CQuestion& q){
		this->text = q.text;
		this->answer = q.answer;
		this->id = q.id;
		this->inquiz = q.inquiz;
		this->player_answer = q.player_answer;
	}
	void operator=(const CQuestion& q){
		this->text = q.text;
		this->answer = q.answer;
		this->id = q.id;
		this->inquiz = q.inquiz;
		this->player_answer = q.player_answer;
	}
	CQuestion(vector<string>& los, int i){

		if (los.size() <= i) { id = -1; return; }
		text = los[i++];
		if (los.size() <= i) { id = -1; return; }
		answer = los[i];
		this->id = ++count;
	}
	bool inputPlayerAnswer(){
		cin >> this->player_answer;
		if (this->player_answer == this->answer)
			return 1;
		return 0;
	}
	bool valid(){
		for (int i = 0; i < text.length() - 2; ++i){
			if (text[i] == '.' && text[i + 1] == '.' && text[i + 2] == '.') return 1;
		}
		return 0;
	}
	friend istream& operator>>(istream& in, CQuestion& q){
		cout << "\nEnter complete question text:\n\n";
		do{
			getline(in, q.text);
		} while (q.text.empty());
		while (!q.valid()) {
			cout << "Error invalid format! Please try again.\n";
			getline(in, q.text);

		}
		cout << "\nEnter correct answer:\n\n";
		in >> q.answer;
		q.id = ++(q.count);
		q.inquiz = 0;

		return in;
	}
};

// ================================================================================================================================
class QuestionBank{
	vector<MCQuestion> lomcq;
	vector<TFQuestion> lotfq;
	vector<CQuestion> locq;
public:
	friend class Quiz;
	int getCount() const{
		return lomcq[0].getCount();
	}
	int mcqSize() const{ return lomcq.size(); }
	int tfqSize() const{ return lotfq.size(); }
	int cqSize() const{ return locq.size(); }
	int size() const{ return mcqSize() + tfqSize() + cqSize(); }
	void addQuestion(const MCQuestion& q){
		MCQuestion temp(q);
		lomcq.push_back(temp);
	}
	void addQuestion(const TFQuestion& q){
		TFQuestion temp(q);
		lotfq.push_back(temp);
	}
	void addQuestion(const CQuestion& q){
		CQuestion temp(q);
		locq.push_back(temp);
	}
	void printQuestions(bool inquiz){
		cout << "---------------------------------------------------\n";
		cout << "MC Questions list (Total: " << lomcq.size() << " Questions):\n";
		cout << "---------------------------------------------------\n";

		for (int i = 0; i < lomcq.size(); ++i){
			lomcq[i].setInQuiz(inquiz);
			cout << lomcq[i];
			cout << "Your answer: " << lomcq[i].getPlayerAnswer() << endl;
		}

		cout << "---------------------------------------------------\n";
		cout << "TF Questions list (Total: " << lotfq.size() << " Questions):\n";
		cout << "---------------------------------------------------\n";
		for (int i = 0; i < lotfq.size(); ++i){
			lotfq[i].setInQuiz(inquiz);
			cout << lotfq[i];
			cout << "Your answer: " << lotfq[i].getPlayerAnswer() << endl;
		}

		cout << "---------------------------------------------------\n";
		cout << "Complete Questions list (Total: " << locq.size() << " Questions):\n";
		cout << "---------------------------------------------------\n";
		for (int i = 0; i < locq.size(); ++i){
			locq[i].setInQuiz(inquiz);
			cout << locq[i];
			cout << "Your answer: " << locq[i].getPlayerAnswer() << endl;
		}
		cout << "\n-------------------------------------------------------------------------------------\n";
	}
	void loadQuestions(string& file_name){
		ifstream fin;
		fin.open(file_name.c_str());                    // open file
		vector <string> los;
		string str;
		while (getline(fin, str)){              // transfer all lines in file to a list of string
			los.push_back(str);
		}
		fin.close();
		for (int i = 0; i < los.size(); ++i){
			if (los[i] == "MCQ"){

				MCQuestion q(los, i + 1);
				if (q.getId() == -1){
					cout << "Error! invalid format!\n";
					break;
				}
				lomcq.push_back(q);
				i += 5;
			}
			else if (los[i] == "TF"){
				TFQuestion q(los, i + 1);
				if (q.getId() == -1){
					cout << "Error! invalid format!\n";
					break;
				}
				lotfq.push_back(q);
				i += 2;
			}
			else if (los[i] == "COMPLETE"){
				CQuestion q(los, i + 1);
				if (q.getId() == -1){
					cout << "Error! invalid format!\n";
					break;
				}
				locq.push_back(q);
				i += 2;
			}
			else {
				cout << "Error! invalid format!\n";
				break;
			}
		}
	}
	MCQuestion getMCQuestion(vector<bool>& vis) const{
		int rn;
		do{
			rn = rand() % lomcq.size();
		} while (vis[lomcq[rn].getId()] == 1);
		return lomcq[rn];
	}
	TFQuestion getTFQuestion(vector<bool>& vis) const{
		int rn;
		do{
			rn = rand() % lotfq.size();
		} while (vis[lotfq[rn].getId()] == 1);
		return lotfq[rn];
	}
	CQuestion getCQuestion(vector<bool>& vis) const{
		int rn;
		do{
			rn = rand() % locq.size();
		} while (vis[locq[rn].getId()] == 1);
		return locq[rn];
	}
	void deleteQuestion(int id){
		for (int i = 0; i < lomcq.size(); ++i)
		if (lomcq[i].getId() == id){
			swap(lomcq[i], lomcq.back());
			lomcq.pop_back();
		}
		for (int i = 0; i < lotfq.size(); ++i)
		if (lotfq[i].getId() == id){
			swap(lotfq[i], lotfq.back());
			lotfq.pop_back();
		}
		for (int i = 0; i < locq.size(); ++i)
		if (locq[i].getId() == id){
			swap(locq[i], locq.back());
			locq.pop_back();
		}

	}
};

// ================================================================================================================================
class Quiz{
	QuestionBank questions;
public:
	Quiz(const QuestionBank& qb){
		if (MCQPQ > qb.mcqSize() || TFQPQ > qb.tfqSize() || CQPQ > qb.cqSize()) { cout << "Error! Not Enought Questions in Question Bank!!!\n"; return; }
		vector<bool> vis(qb.getCount() + 1);
		for (int i = 0; i < vis.size(); ++i) vis[i] = 0;
		for (int i = 0; i < MCQPQ; ++i){
			MCQuestion mcq = (qb.getMCQuestion(vis));
			questions.addQuestion(mcq);
			vis[mcq.getId()] = 1;
		}
		for (int i = 0; i < TFQPQ; ++i){
			TFQuestion tfq = (qb.getTFQuestion(vis));
			questions.addQuestion(tfq);
			vis[tfq.getId()] = 1;
		}
		for (int i = 0; i < CQPQ; ++i){
			CQuestion cq = (qb.getCQuestion(vis));
			questions.addQuestion(cq);
			vis[cq.getId()] = 1;
		}


	}
	void printQuestions(bool inquiz){
		questions.printQuestions(inquiz);
	}
	int takeQuiz(){
		int score = 0;
		cout << "---------------------------------------------------\n";
		cout << "MC Questions list (Total: " << questions.mcqSize() << " Questions):\n";
		cout << "---------------------------------------------------\n";

		for (int i = 0; i < questions.mcqSize(); ++i){
			questions.lomcq[i].setInQuiz(1);
			cout << questions.lomcq[i];
			if (questions.lomcq[i].inputPlayerAnswer()){
				score += MCQ_MARK;
				cout << "Correct!\n";
			}
			else cout << "Incorrect!\n";
		}
		cout << "---------------------------------------------------\n";
		cout << "TF Questions list (Total: " << questions.tfqSize() << " Questions):\n";
		cout << "---------------------------------------------------\n";

		for (int i = 0; i < questions.tfqSize(); ++i){
			questions.lotfq[i].setInQuiz(1);
			cout << questions.lotfq[i];
			if (questions.lotfq[i].inputPlayerAnswer()){
				score += TFQ_MARK;
				cout << "Correct!\n";
			}
			else cout << "Incorrect!\n";
		}
		cout << "---------------------------------------------------\n";
		cout << "Complete Questions list (Total: " << questions.cqSize() << " Questions):\n";
		cout << "---------------------------------------------------\n";

		for (int i = 0; i < questions.cqSize(); ++i){
			questions.locq[i].setInQuiz(1);
			cout << questions.locq[i];
			if (questions.locq[i].inputPlayerAnswer()){
				score += CQ_MARK;
				cout << "Correct!\n";
			}
			else cout << "Incorrect!\n";
		}
		return score;
	}
	int size(){
		return questions.size();
	}
};

// ================================================================================================================================

// ================================================================================================================================

class User{
protected:
	string username;
	string password;
	string first_name;
	string last_name;
public:
	User(string& username, string& password){
		this->username = username, this->password = password, this->first_name = "user", this->last_name = "user";
	}
	void updateName(string& first_name, string& last_name){
		this->first_name = first_name, this->last_name = last_name;
	}
	string getUsername(){
		return username;
	}
	string getPassword(){
		return password;
	}
	string getFirstName(){
		return first_name;
	}
	string getLastName(){
		return last_name;
	}

};

// ================================================================================================================================
class Player : public User{

	int no_quizes;
	int hi_score = -1;
	int lo_score = -1;
	int sum_score;
	double avg_score;
	int mcq_score;
	int tf_score;
	int c_score;
	double avg_mcq;
	double avg_tf;
	double avg_c;
	vector<Quiz> loq;
	vector<int> scores;
public:
	Player(string& username, string& password) : User(username, password){

		int no_quizes = 0;
		int hi_score = -1;
		int lo_score = -1;
		int sum_score = 0;
		double avg_score = -1;
		int mcq_score = -1;
		int tf_score = -1;
		int c_score = -1;
		double avg_mcq = -1;
		double avg_tf = -1;
		double avg_c = -1;
	}
	void startQuiz(const QuestionBank& qb){
		Quiz quiz(qb);
		if (!quiz.size()) return;
		int score = quiz.takeQuiz();

		this->loq.push_back(quiz);

		scores.push_back(score);
		no_quizes++;
		sum_score += score;
		if (lo_score == -1) hi_score = score, lo_score = score;
		hi_score = max(hi_score, score);
		lo_score = min(lo_score, score);
		avg_score = (double)sum_score / no_quizes;
	}
	void printStats(){
		if (no_quizes == 0) { cout << "You still didn't take any quizes! Please start a quiz from the main menu\n"; return; }
		cout << "\n\n";
		cout << "Your score statistics:\n";
		cout << "           " << "- Number of Quizzes taken: " << no_quizes << '\n';
		cout << "           " << "- Highest score: " << hi_score << '/' << QPQ << '\n';
		cout << "           " << "- Lowest score: " << lo_score << '/' << QPQ << '\n';
		cout << "           " << "- Average score: " << setprecision(4) << avg_score << '/' << QPQ << '\n\n';
	}

	void printScores(){
		if (no_quizes == 0) { cout << "You still didn't take any quizes! Please start a quiz from the main menu\n"; return; }
		for (int score : scores){
			cout << "The quiz's report:\n";
			cout << "    " << "Right answers: " << score << '\n';
			cout << "    " << "Wrong answers: " << QPQ - score << '\n';
			cout << "    " << "You scored: " << score << '/' << QPQ << '\n';
		}
	}
	void printQuizes(){
		if (no_quizes == 0) { cout << "You still didn't take any quizes! Please start a quiz from the main menu\n"; return; }
		loq[loq.size() - 1].printQuestions(0);
		cout << "\n-----------------------------------------------------------------------\n";
		if (no_quizes < 2) return;
		loq[loq.size() - 2].printQuestions(0);
		cout << "\n-----------------------------------------------------------------------\n";
	}
};

// ================================================================================================================================
class Admin : public User{

public:

	Admin(string& username, string& password) :User(username, password){}
	void addUser(pair<vector<Admin>, vector<Player> >& lou, string username, string password, bool isAdmin){
		for (Admin a : lou.first) if (a.getUsername() == username) { cout << "Username already taken! Please try another.\n"; }
		for (Player p : lou.second) if (p.getUsername() == username) { cout << "Username already taken! Please try another.\n"; };
		if (isAdmin){
			Admin temp(username, password);
			lou.first.push_back(temp);
		}
		else{
			Player temp(username, password);
			lou.second.push_back(temp);
		}
	}
	void printUsers(const pair<vector<Admin>, vector<Player> >& lou) const{
		cout << "Existing users in the system:\n";
		cout << left << setw(17) << "First name" << left << setw(17) << "Last Name" << left << setw(17) << "Username" << left << setw(17) << "Role" << endl;
		for (Admin a : lou.first) printUser(a, 1);
		for (Player p : lou.second) printUser(p, 0);
	}
	void printUser(User u, bool is_admin) const{
		cout << left << setw(17) << u.getFirstName() << left << setw(17) << u.getLastName() << left << setw(17) << u.getUsername() << left << setw(17) << (is_admin ? "admin" : "player") << endl;
	}
};



int main(){
	string username = "username", password = "password", type = "Y";
	Admin admin(username, password);

	pair<vector<Admin>, vector<Player> > lou; lou.first.push_back(admin);
	string file_name = "exam2_questions.txt";
	QuestionBank qb; qb.loadQuestions(file_name);

	cout << "*******************************************************************\n";
	cout << "				Welcome to the Quiz game program V2.0!\n";
	cout << "*******************************************************************\n";
	while (true){
		cout << "Please enter your username : ";
		cin >> username;
		cout << "Please enter your password : ";
		cin >> password;
		string first_name = "", last_name = "", text = "", choices[CHOICES]; bool switch_user = 0, found = 0; char ch; int id = 0;
		for (int i = 0; i < lou.first.size(); ++i) if (lou.first[i].getUsername() == username && lou.first[i].getPassword() == password){
			found = 1;
			while (!switch_user){
				cout << "\n\nWelcome " << lou.first[i].getFirstName() << ' ' << lou.first[i].getLastName() << " (ADMIN), please choose from the following options:\n";
				cout << "      [1] Switch accounts" << endl;
				cout << "      [2] Update your name" << endl;
				cout << "      [3] View all users" << endl;
				cout << "      [4] Add new user" << endl;
				cout << "      [5] View all questions" << endl;
				cout << "      [6] Add new question" << endl;
				cout << "      [7] Load questions from file" << endl;
				cout << "      [8] Exit the program" << endl;
				cout << "My choice: ";
				int choice; input(choice, 1, 8);

				switch (choice){
				case 1:
					switch_user = 1;
					break;
				case 2:
					cout << "Enter first name: "; do getline(cin, first_name); while (first_name.empty());
					cout << "Enter last name: "; do getline(cin, last_name); while (last_name.empty());
					lou.first[i].updateName(first_name, last_name);
					break;
				case 3:
					lou.first[i].printUsers(lou);
					break;
				case 4:
					cout << "Enter username: "; do getline(cin, username); while (username.empty());
					cout << "Enter password: "; do getline(cin, password); while (password.empty());
					cout << "is user an admin?(Y/N): "; do {getline(cin, type); }while (type.empty() || (type != "Y" && type != "N"));
					lou.first[i].addUser(lou, username, password, type == "Y");
					username = "", password = "";
					break;
				case 5:
					while (true){
						qb.printQuestions(0);
						cout << "Press [d] and the question ID if you want to delete a question (Example: d 2)\n";
						cout << "Press [b] if you want to go back to the main menu\n";
						do cin >> ch; while (ch != 'd' && ch != 'b');
						cin.ignore();
						if (ch == 'd'){
							cin >> id;
							cin.ignore();
							qb.deleteQuestion(id);
						}
						else break;
					}
					break;
				case 6:
					cout << "[1]Add an MCQ question\n";
					cout << "[2]Add a TF question\n";
					cout << "[3]Add a Complete question\n";
					input(choice, 1, 3);
					if (choice == 1){
						MCQuestion q; cin >> q;
						qb.addQuestion(q);
					}
					else if (choice == 2){
						TFQuestion q; cin >> q;
						qb.addQuestion(q);
					}
					else{
						CQuestion q; cin >> q;
						qb.addQuestion(q);
					}
					break;
				case 7:
					cout << "Enter file name: ";
					do getline(cin, file_name); while (file_name.empty());
					qb.loadQuestions(file_name);
					break;
				case 8:
					return 0;
				}
			}
		}
		for (int i = 0; i < lou.second.size(); ++i) if (lou.second[i].getUsername() == username && lou.second[i].getPassword() == password){
			found = 1;
			while (!switch_user){
				cout << "\n\nWelcome " << lou.second[i].getFirstName() << ' ' << lou.second[i].getLastName() << " (PLAYER), please choose from the following options : \n";
				cout << "      [1] Switch accounts\n";
				cout << "      [2] Update your name\n";
				cout << "      [3] Start a new quiz\n";
				cout << "      [4] Display your scores statistics\n";
				cout << "      [5] Display all your scores\n";
				cout << "      [6] Display details of your last 2 quizzes\n";
				cout << "      [7] Exit the program\n";
				int choice; input(choice, 1, 8);

				switch (choice){
				case 1:
					switch_user = 1;
					break;
				case 2:
					cout << "Enter first name: "; do getline(cin, first_name); while (first_name.empty());
					cout << "Enter last name: "; do getline(cin, last_name); while (last_name.empty());
					lou.second[i].updateName(first_name, last_name);
					break;
				case 3:
					lou.second[i].startQuiz(qb);
					break;
				case 4:
					lou.second[i].printStats();
					break;
				case 5:
					lou.second[i].printScores();
					break;
				case 6:
					lou.second[i].printQuizes();
					break;
				case 7:
					return 0;
				}
			}
		}
		if (!found)
			cout << "Login failed! Please try again.\n";
	}
	return 0;
}
