char Message[100];
int strlen = 0;
int x = 1;
int y = 1;
int strt = 31;
char startingMsg[] = "Welcome!Type help for more info.\n";
char helpMsg[] = "Command list:\nls - Show list of process.\n1~4 - Select process you want to run.\ncln - Clean up the screen.\ninfo [programname]: more info for selected program\n";
char errorMsg[] = "Command not found.Please check your input.\n";
char exitMsg[] = "Do you want to clean up the screen?[Y/N]";
char lsTable[] = "1.Pg_1.com\n2.Pg_2.com\n3.Pg_3.com\n4.Pg_4.com";
char inf[] = "Address:800H:100H Sector:2 Size: 3sec\n";
char inf_Pg1[] = "Address:900H:100H Sector:5 Size: 1sec\n";
char inf_Pg2[] = "Address:900H:300H Sector:6 Size: 1sec\n";
char inf_Pg3[] = "Address:900H:500H Sector:7 Size: 1sec\n";
char inf_Pg4[] = "Address:900H:700H Sector:8 Size: 1sec\n";
char cmd[] = "MyOS>";
char keyboardInput[30];
enum opp{help,ls,error,cleanup};
/*进程PCB*/
int ProcessNum = 1;
int currentProcNum = 0;
typedef struct PCB
{
	int ax;
	int bx;
	int cx;
	int dx;
	int si;
	int di;
	int bp;
	int es;
	int ds;
	int ss;
	int sp;
	int ip;
	int cs;
	int flags;
	int status;
	char p_name;
};
struct PCB PCBlist[5];
struct PCB * CurrentProc = PCBlist;
extern put(char,int);
extern changeline();
extern clean();
extern input();
extern proc_Pg_1();
extern proc_Pg_2();
extern proc_Pg_3();
void printf(const char*);

test(){
	new_proc(1);
	new_proc(2);
	new_proc(3);
}

main(){
	int k = 0;
	printf(startingMsg);
	while(1){
		printf(cmd);
		input();
		cmd_dispatch();
		k = 0;
		while (keyboardInput[k]){
			keyboardInput[k] = 0;
			k ++;
		}
	}
}
cmd_Dispatch(){
    if (!strcmp(keyboardInput,"help")){
        proc_display(help);
	}
    else if (!strcmp(keyboardInput,"ls"))
        proc_display(ls);
    else if (!strcmp(keyboardInput,"cln"))
        proc_display(cleanup);
	else if (!strcmp(keyboardInput,"info")){
		printf(inf);
    }
	else if (!strcmp(keyboardInput,"info pg1")){
		printf(inf_Pg1);
    }
	else if (!strcmp(keyboardInput,"info pg2")){
		printf(inf_Pg2);
    }
	else if (!strcmp(keyboardInput,"info pg3")){
		printf(inf_Pg3);
    }
	else if (!strcmp(keyboardInput,"info pg4")){
		printf(inf_Pg4);
    }
    else if (!strcmp(keyboardInput,"1"))
        new_proc(1);
    else if (!strcmp(keyboardInput,"2"))
        new_proc(2);
    else if (!strcmp(keyboardInput,"3"))
        new_proc(3);
    else
        proc_display(error);

}
int strcmp (const char *str1,const char *str2)
{           
       while(*str1 && *str2 && (*str1 == *str2))
       {
              str1++;
              str2++;
       }
       return *str1-*str2;
}
int proc_display(int stat){
    if (stat == help){
        printf(helpMsg);
	}
    else if (stat == error){
        printf(errorMsg);
	}
    else if (stat == ls){
        printf(lsTable);
		changeline();
	}
    else if (stat == cleanup){
        clean();
    }
}
new_proc(int i){
	ProcessNum ++;
	if (i == 1)
		PCB_init(ProcessNum - 1,0x900,0x100,0x900,0x900,0x500);
	else if (i == 2)
		PCB_init(ProcessNum - 1,0x900,0x300,0x900,0x900,0x600);
	else
		PCB_init(ProcessNum - 1,0x900,0x500,0x900,0x900,0x700);
}
void printf(const char * str){
	int i = 0;
	strlen = 0;
	while(str[i]){
		if(str[i] == '\n'){
			changeline();
			i ++;
			continue;
		}
		put(str[i],7);
		Message[i] = str[i];
		strlen ++;
		i ++;
	}
}

PCB_init(int n,int cs,int ip,int ds,int es, int ss){
	PCBlist[n].cs = cs;
	PCBlist[n].ip = ip;
	PCBlist[n].ds = ds;
	PCBlist[n].es = es;
	PCBlist[n].ss = ss;
	PCBlist[n].sp = 0x100;
	PCBlist[n].flags = 512;
}

schedule(){
	currentProcNum ++;
	if (currentProcNum >= ProcessNum){
		currentProcNum = 0;
		CurrentProc = &PCBlist[0];
	}
	else
		CurrentProc = &PCBlist[currentProcNum];
}
