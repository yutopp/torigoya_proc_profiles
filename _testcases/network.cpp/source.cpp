//http://dixq.net/forum/viewtopic.php?f=3&t=7283
//まずい

#include<iostream>
#include<cstdio>
#include<netdb.h>
#include<errno.h>
#include <string.h>

 
using namespace std;
 
const int cBufferLength= 1024;
extern int errno;
 
string::size_type
parseURL(string url,string& host,string& service,string& path)
{
        string::size_type pindex,index;
        if(url.find("http://") == string::npos){
                return string::npos;
        }
        host = url.substr(7);
        if((pindex = host.find("/")) == string::npos){
                return string::npos;
        }
 
        path = host.substr(pindex);
        host = host.substr(0,pindex);
        if((index = host.find(":")) == string::npos){
                service = "80";
        }else{
                service = host.substr(index+1);
                host = host.substr(0,index);
        }
        return pindex;
}
 
int main(int argc,char *argv[])
{
        string url = "http://www.google.com/";
 
        string host,service,path;
        parseURL(url,host,service,path);
 
        struct addrinfo addrHints;
        struct addrinfo *addrInfo;
        int errCode;
 
        memset(&addrHints,0,sizeof(addrHints));
        addrHints.ai_family = PF_INET;
 
        addrHints.ai_socktype = SOCK_STREAM;
 
        if((errCode = getaddrinfo(host.c_str(),service.c_str(),&addrHints,&addrInfo)) != 0){
 
                cerr<<"getaddrinfo failed for "<<host<<", "<<service<<", ";
                cerr<<gai_strerror(errCode)<<endl;
                return(2);
        }
 
        int connSock;
        if((connSock = socket(addrInfo->ai_family,addrInfo->ai_socktype,addrInfo->ai_protocol)) < 0){
 
        cerr<<"failed to open socket"<<strerror(errno)<<endl;
        return(3);
        }
 
                if((connect(connSock,addrInfo->ai_addr,addrInfo->ai_addrlen)) != 0){
 
        cerr<<"failed to bind socket"<<strerror(errno)<<endl;
        return(4);
        }
 
        FILE* sockFP;
        string request ,workbuf;
        char buffer[cBufferLength];
        bool output = false;
 
        if((sockFP =fdopen(connSock,"r+")) == NULL ){
 
                cerr<<"failed on opening socket stream"<<endl;
                return(5);
        }
        request = "GET " + path + " HTTP/1.1\r\n";
        request += ("Host: " + host +"\r\n");
        request += "Connection: close\r\n\r\n";
 
                fputs(request.c_str(),sockFP);
 
        while(fgets(buffer,cBufferLength - 1,sockFP) != NULL){
        workbuf = buffer;
        if(output){
         cout<<buffer;
        }
        if(workbuf.find("\r\n") == 0){
                output = true;
        }
        }
        return(0);
}
