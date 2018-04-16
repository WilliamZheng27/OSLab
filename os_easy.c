char Message[100];
int strlen = 0;
int x = 1;
int y = 1;
int strt = 31;
char startingMsg[] = "Welcome!Type help for more info.\n";
char helpMsg[] = "Command list:\nls - Show list of process.\n1~4 - Select process you want to run.\ncln - Clean up the screen.\ninfo [programname]: more info for selected program";
char errorMsg[] = "Command not found.Please check your input.\n";
char exitMsg[] = "Do you want to clean up the screen?[Y/N]";
char lsTable[] = "1.Pg_1.com2.Pg_2.com3.Pg_3.com4.Pg_4.com";
char inf[] = "Address:800H:100H Sector:2 Size: 3sec";
char inf_Pg1[] = "Address:900H:100H Sector:5 Size: 1sec";
char inf_Pg2[] = "Address:900H:300H Sector:6 Size: 1sec";
char inf_Pg3[] = "Address:900H:500H Sector:7 Size: 1sec";
char inf_Pg4[] = "Address:900H:700H Sector:8 Size: 1sec";
char cmd[] = "MyOS>";
char keyboardInput[30];
enum opp{help,ls,error,cleanup};
extern put(char,int);
extern changeline();
extern clean();
extern input();
extern proc_Pg_1();
void printf(const char*);
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
		changeline();
        proc_display(help);
		changeline();
	}
    else if (!strcmp(keyboardInput,"ls"))
        proc_display(ls);
    else if (!strcmp(keyboardInput,"cln"))
        proc_display(cleanup);
	else if (!strcmp(keyboardInput,"info")){
		changeline();
		printf(inf);
		changeline();
    }
	else if (!strcmp(keyboardInput,"info pg1")){
		changeline();
		printf(inf_Pg1);
		changeline();
    }
	else if (!strcmp(keyboardInput,"info pg2")){
		changeline();
		printf(inf_Pg2);
		changeline();
    }
	else if (!strcmp(keyboardInput,"info pg3")){
		changeline();
		printf(inf_Pg3);
		changeline();
    }
	else if (!strcmp(keyboardInput,"info pg4")){
		changeline();
		printf(inf_Pg4);
		changeline();
    }
    else if (!strcmp(keyboardInput,"1"))
        proc_Pg_1();
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

