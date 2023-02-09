#include <vector>
#include <fstream>
using namespace std;

class TreeNode {
    public:

        virtual ~TreeNode() {}
        string nodeName;
        bool isLeaf;
        int start;
        int end;
        vector<TreeNode*> children;
};

class SymbolInfo : public TreeNode {
private:
    string name;
    string type;
    string retType;
    SymbolInfo *next;

public:
    vector<string> paramList;
    vector<string> paramType;
    bool isDef;
    int width;
    int offset;
    string asmType;
    string address;

    SymbolInfo()
    {
        isDef = false;
    }

    SymbolInfo(string n, string t)
    {
        name = n;
        type = t;
        next = NULL;
        isDef = false;
    }

    string getName()
    {
        return name;
    }

    string getType()
    {
        return type;
    }

    string getRetType()
    {
        return retType;
    }

    SymbolInfo* getNext()
    {
        return next;
    }

    void setName(string n)
    {
        name = n;
    }

    void setType(string t)
    {
        type = t;
    }

    void setRetType(string r)
    {
        retType = r;
    }

    void setNext(SymbolInfo *nx)
    {
        next = nx;
    }

};

class ScopeTable {
private:
    ScopeTable *parent;
    int bucketSize;
    SymbolInfo **hashTable;
    int scopeID;

public:
    int offset;

    ScopeTable(int s)
    {
        bucketSize = s;
        hashTable = new SymbolInfo*[bucketSize];
        for(int i=0; i<bucketSize; i++){
            hashTable[i] = NULL;
        }
        parent = NULL;
    }

    ScopeTable(int s, int id)
    {
        bucketSize = s;
        scopeID = id;
        hashTable = new SymbolInfo*[bucketSize];
        for(int i=0; i<bucketSize; i++){
            hashTable[i] = NULL;
        }
        parent = NULL;
    }

    ~ScopeTable()
    {
        SymbolInfo *element, *next;
        for(int i=0; i<bucketSize; i++){
            element = hashTable[i];
            while(element != NULL){
                next = element->getNext();
                delete element;
                element = next;
            }
        }
        delete[] hashTable;
    }

    unsigned long long sdbm_hash(string name)
    {
        unsigned long long hash = 0;
        unsigned int i;
        unsigned int len = name.length();

        for (i = 0; i < len; i++){
            hash = ((name[i]) + (hash << 6) + (hash << 16) - hash);
        }

        return hash%bucketSize;
    }

    ScopeTable* getParent()
    {
        return parent;
    }

    int getID()
    {
        return scopeID;
    }

    void setParent(ScopeTable *p)
    {
        parent = p;
    }

    void setID(int ID)
    {
        scopeID = ID;
    }

    bool insert(SymbolInfo *symbol)
    {
        int pos = 1;
        unsigned int hash = sdbm_hash(symbol->getName());
        if(hashTable[hash] == NULL){
            hashTable[hash] = symbol;
            symbol->setNext(NULL);
            return true;
        }
        SymbolInfo *element;
        element = hashTable[hash];
        pos++;
        while(true){
            if(element->getName().compare(symbol->getName()) == 0){
                return false;
            }
            if(element->getNext() == NULL){
                element->setNext(symbol);
                return true;
            }
            element = element->getNext();
            pos++;
        }
    }

    SymbolInfo* lookUp(string n)
    {
        int pos = 1;
        unsigned int hash = sdbm_hash(n);
        SymbolInfo *element = hashTable[hash];
        while(element){
            if(element->getName().compare(n) == 0){
                return element;
            }
            element = element->getNext();
            pos++;
        }
        return NULL;
    }

    bool deleteSymbol(string n)
    {
        int pos = 1;
        unsigned int hash = sdbm_hash(n);
        SymbolInfo *element = hashTable[hash];
        if(element == NULL){
            return false;
        }
        if(element->getName().compare(n) == 0){
            hashTable[hash] = element->getNext();
            delete element;
            return true;
        }
        SymbolInfo *prev = element;
        element = element->getNext();
        pos++;
        while(element){
            if(element->getName().compare(n) == 0){
                prev->setNext(element->getNext());
                delete element;
                return true;
            }
            prev = element;
            element = element->getNext();
            pos++;
        }
        return false;
    }

    void print(ofstream &fp)
    {
        fp<<"\tScopeTable# "<<scopeID<<endl;
        for(int i=0; i<bucketSize; i++){
            if(hashTable[i] == NULL){
                continue;
            }
            fp<<"\t"<<i+1<<"--> ";
            SymbolInfo *element = hashTable[i];
            while(element != NULL){
                if(element->getType() == "FUNCTION" || element->getType() == "ARRAY"){
                    fp<<"<"<<element->getName()<<", "<<element->getType()<<", "<<element->getRetType()<<"> ";
                }
                else{
                    fp<<"<"<<element->getName()<<", "<<element->getType()<<"> ";
                }
                element = element->getNext();
            }
            fp<<endl;
        }
    }

};

class SymbolTable {
private:
    int scopeCount;
    ScopeTable *current;
    int bucketSize;

public:

    SymbolTable(int n)
    {
        scopeCount = 0;
        bucketSize = n;
        current = NULL;
        enterScope();
    }

    ~SymbolTable()
    {
        ScopeTable *now;
        while(current != NULL){
            now = current->getParent();
            delete current;
            current = now;
        }
    }

    void enterScope()
    {
        scopeCount++;
        ScopeTable *now = new ScopeTable(bucketSize, scopeCount);
        now->setParent(current);
        current = now;
        if(current->getParent() == NULL){
            current->offset = 0;
        }
        else{
            current->offset = current->getParent()->offset;
        }
    }

    void exitScope()
    {
        ScopeTable *p = current->getParent();
        if(p == NULL){
            return;
        }
        delete current;
        current = p;
    }

    bool insert(string name, string type)
    {
        SymbolInfo *symbol = new SymbolInfo(name, type);
        if(!current->insert(symbol)){
            delete symbol;
            return false;
        }
        return true;
    }

     bool insert(string name, string type, string rt)
    {
        SymbolInfo *symbol = new SymbolInfo(name, type);
        symbol->setRetType(rt);
        if(!current->insert(symbol)){
            delete symbol;
            return false;
        }
        return true;
    }

    bool insert(SymbolInfo *si)
    {
        if(!current->insert(si)){
            delete si;
            return false;
        }
        return true;
    }

    bool remove(string name)
    {
        return current->deleteSymbol(name);
    }

    SymbolInfo *lookUp(string name)
    {
        ScopeTable *now = current;
        SymbolInfo *symbol;
        while(now != NULL){
            symbol = now->lookUp(name);
            if(symbol){
                return symbol;
            }
            now = now->getParent();
        }
        return NULL;
    }

    SymbolInfo *lookUpCurrent(string name)
    {
        return current->lookUp(name);
    }

    void printCurrent(ofstream &fp)
    {
        current->print(fp);
    }

    void printAll(ofstream &fp)
    {
        ScopeTable *now = current;
        while(now){
            now->print(fp);
            now = now->getParent();
        }
    }

    bool isGlobal()
    {
        return current->getParent() == NULL;
    }

    int getOffset()
    {
        return current->offset;
    }

    void setOffset(int o)
    {
        if(current->getParent() != NULL){
            current->offset = o;
        }
    }

};

class Symbols : public TreeNode {
public:

vector<SymbolInfo> v;

~Symbols()
{
    clr();
}    

void insert(SymbolInfo s)
{
    v.push_back(s);
}

int length()
{
    return v.size();
}

void clr()
{
    while(v.size()){
        v.clear();
    }
}

};

class TreeHelp { 
    public:

    static void printTree(ofstream &fp, TreeNode* node, int level)
    {
        for(int i=0; i<level; i++){
            fp<<" ";
        }
        if(node->isLeaf){
            fp<<node->nodeName<<"\t"<<"<Line: "<<node->start<<">"<<endl;
        }
        else{
            fp<<node->nodeName<<" \t"<<"<Line: "<<node->start<<"-"<<node->end<<">"<<endl;
            for(int i=0; i<node->children.size(); i++){
                printTree(fp, node->children[i], level+1);
            }
        }
    }    

    static void deleteTree(TreeNode *node)
    {
        for(int i=0; i<node->children.size(); i++){
            deleteTree(node->children[i]);
        }
        delete node;

    }

};