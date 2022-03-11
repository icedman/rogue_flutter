/*
 * save and restore routines
 *
 * @(#)save.c	4.33 (Berkeley) 06/01/83
 *
 * Rogue: Exploring the Dungeons of Doom
 * Copyright (C) 1980-1983, 1985, 1999 Michael Toy, Ken Arnold and Glenn Wichman
 * All rights reserved.
 *
 * See the file LICENSE.TXT for full copyright and licensing information.
 */

#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <signal.h>
#include <string.h>
#include <curses.h>
#include "rogue.h"
#include "score.h"

/*
 * save_game:
 *	Implement the "save game" command
 */

void
save_game(void)
{
#if 0
    FILE *savef;
    int c;
    char buf[MAXSTR];
    struct stat sbuf;
    /*
     * get file name
     */
    mpos = 0;
over:
    if (file_name[0] != '\0')
    {
	for (;;)
	{
	    msg("save file (%s)? ", file_name);
	    c = readchar();
	    mpos = 0;
	    if (c == ESCAPE)
	    {
		msg("");
		return;
	    }
	    else if (c == 'n' || c == 'N' || c == 'y' || c == 'Y')
		break;
	    else
		msg("please answer Y or N");
	}
	if (c == 'y' || c == 'Y')
	{
	    addstr("Yes\n");
	    refresh();
	    strcpy(buf, file_name);
	    goto gotfile;
	}
    }

    do
    {
	mpos = 0;
	msg("file name: ");
	buf[0] = '\0';
	if (get_str(buf, stdscr) == QUIT)
	{
quit_it:
	    msg("");
	    return;
	}
	mpos = 0;
gotfile:
	/*
	 * test to see if the file exists
	 */
	if (stat(buf, &sbuf) >= 0)
	{
	    for (;;)
	    {
		msg("File exists.  Do you wish to overwrite it?");
		mpos = 0;
		if ((c = readchar()) == ESCAPE)
		    goto quit_it;
		if (c == 'y' || c == 'Y')
		    break;
		else if (c == 'n' || c == 'N')
		    goto over;
		else
		    msg("Please answer Y or N");
	    }
	    msg("file name: %s", buf);
	    md_unlink(file_name);
	}
	strcpy(file_name, buf);
	if ((savef = fopen(file_name, "w")) == NULL)
	    msg(strerror(errno));
    } while (savef == NULL);
    msg("");
    save_file(savef);
    /* NOTREACHED */
#endif
}

/*
 * auto_save:
 *	Automatically save a file.  This is used if a HUP signal is
 *	recieved
 */

void
auto_save(int sig)
{
#if 0
    FILE *savef;
    NOOP(sig);

    md_ignoreallsignals();
    if (file_name[0] != '\0' && ((savef = fopen(file_name, "w")) != NULL ||
	(md_unlink_open_file(file_name, savef) >= 0 && (savef = fopen(file_name, "w")) != NULL)))
	    save_file(savef);
    exit(0);
#endif
}

/*
 * save_file:
 *	Write the saved game on the file
 */

void
save_file(FILE *savef)
{
#if 0
    char buf[80];
    mvcur(0, COLS - 1, LINES - 1, 0); 
    putchar('\n');
    endwin();
    resetltchars();
    md_chmod(file_name, 0400);
    encwrite(version, strlen(version)+1, savef);
    sprintf(buf,"%d x %d\n", LINES, COLS);
    encwrite(buf,80,savef);
    rs_save_file(savef);
    fflush(savef);
    fclose(savef);
    exit(0);
#endif
}

/*
 * restore:
 *	Restore a saved game from a file with elaborate checks for file
 *	integrity from cheaters
 */
int
restore(const char *file)
{
#if 0
    FILE *inf;
    int syml;
    char buf[MAXSTR];
    struct stat sbuf2;
    int lines, cols;

    if (strcmp(file, "-r") == 0)
	file = file_name;

	md_tstphold();

	if ((inf = fopen(file,"r")) == NULL)
    {
	perror(file);
	return FALSE;
    }
    stat(file, &sbuf2);
    syml = is_symlink(file);

    fflush(stdout);
    encread(buf, strlen(version) + 1, inf);
    if (strcmp(buf, version) != 0)
    {
	printf("Sorry, saved game is out of date.\n");
	return FALSE;
    }
    encread(buf,80,inf);
    (void) sscanf(buf,"%d x %d\n", &lines, &cols);

    initscr();                          /* Start up cursor package */
    keypad(stdscr, 1);

    if (lines > LINES)
    {
        endwin();
        printf("Sorry, original game was played on a screen with %d lines.\n",lines);
        printf("Current screen only has %d lines. Unable to restore game\n",LINES);
        return(FALSE);
    }
    if (cols > COLS)
    {
        endwin();
        printf("Sorry, original game was played on a screen with %d columns.\n",cols);
        printf("Current screen only has %d columns. Unable to restore game\n",COLS);
        return(FALSE);
    }

    hw = newwin(LINES, COLS, 0, 0);
    setup();

    rs_restore_file(inf);
    /*
     * we do not close the file so that we will have a hold of the
     * inode for as long as possible
     */

    if (
#ifdef MASTER
	!wizard &&
#endif
        md_unlink_open_file(file, inf) < 0)
    {
	printf("Cannot unlink file\n");
	return FALSE;
    }
    mpos = 0;
/*    printw(0, 0, "%s: %s", file, ctime(&sbuf2.st_mtime)); */
/*
    printw("%s: %s", file, ctime(&sbuf2.st_mtime));
*/
    clearok(stdscr,TRUE);
    /*
     * defeat multiple restarting from the same place
     */
#ifdef MASTER
    if (!wizard)
#endif
	if (sbuf2.st_nlink != 1 || syml)
	{
	    endwin();
	    printf("\nCannot restore from a linked file\n");
	    return FALSE;
	}

    if (pstats.s_hpt <= 0)
    {
	endwin();
	printf("\n\"He's dead, Jim\"\n");
	return FALSE;
    }

	md_tstpresume();

    strcpy(file_name, file);
    clearok(curscr, TRUE);
    srand(md_getpid());
    msg("file name: %s", file);
    playit();
    /*NOTREACHED*/
    return(0);
#else
    return FALSE;
#endif
}

static int encerrno = 0;

int
encerror()
{
    return encerrno;
}

void
encseterr(int err)
{
    encerrno = err;
}

int
encclearerr()
{
    int n = encerrno;

    encerrno = 0;

    return(n);
}

/*
 * encwrite:
 *	Perform an encrypted write
 */

size_t
encwrite(const char *start, size_t size, FILE *outf)
{
    const char *e1, *e2;
    char fb;
    int temp;
    size_t o_size = size;
    e1 = encstr;
    e2 = statlist;
    fb = 0;

    if (encerrno) {
	errno = encerrno;
	return 0;
    }

    while(size)
    {
	if (putc(*start++ ^ *e1 ^ *e2 ^ fb, outf) == EOF)
	{
	    encerrno = errno;
            break;
	}

	temp = *e1++;
	fb = fb + ((char) (temp * *e2++));
	if (*e1 == '\0')
	    e1 = encstr;
	if (*e2 == '\0')
	    e2 = statlist;
	size--;
    }

    return(o_size - size);
}

/*
 * encread:
 *	Perform an encrypted read
 */
size_t
encread(char *start, size_t size, FILE *inf)
{
    const char *e1, *e2;
    char fb;
    int temp;
    size_t read_size;
    size_t items;
    fb = 0;

    if (encerrno) {
	errno = encerrno;
	return 0;
    }

    items = read_size = fread(start,1,size,inf);

    e1 = encstr;
    e2 = statlist;

    while (read_size--)
    {
	*start++ ^= *e1 ^ *e2 ^ fb;
	temp = *e1++;
	fb = fb + (char)(temp * *e2++);
	if (*e1 == '\0')
	    e1 = encstr;
	if (*e2 == '\0')
	    e2 = statlist;
    }

    if (items != size)
	encerrno = errno;

    return(items);
}

/*
 * read_scrore
 *	Read in the score file
 */
void
rd_score(SCORE *top_ten)
{
#if 0
    char scoreline[100];
    int i;

    if (scoreboard == NULL)
	return;

    rewind(scoreboard); 

    for(i = 0; i < numscores; i++)
    {
        encread(top_ten[i].sc_name, MAXSTR, scoreboard);
	scoreline[0] = '\0';
        encread(scoreline, 100, scoreboard);
        (void) sscanf(scoreline, " %u %d %u %d %d %x \n",
            &top_ten[i].sc_uid, &top_ten[i].sc_score,
            &top_ten[i].sc_flags, &top_ten[i].sc_monster,
            &top_ten[i].sc_level, &top_ten[i].sc_time);
    }

    rewind(scoreboard);
#endif
}

/*
 * write_scrore
 *	Read in the score file
 */
void
wr_score(SCORE *top_ten)
{
#if 0
    char scoreline[100];
    int i;

    if (scoreboard == NULL)
	return;

    rewind(scoreboard);

    for(i = 0; i < numscores; i++)
    {
          memset(scoreline,0,100);
          encwrite(top_ten[i].sc_name, MAXSTR, scoreboard);
          sprintf(scoreline, " %u %d %u %u %d %x \n",
              top_ten[i].sc_uid, top_ten[i].sc_score,
              top_ten[i].sc_flags, top_ten[i].sc_monster,
              top_ten[i].sc_level, top_ten[i].sc_time);
          encwrite(scoreline,100,scoreboard);
    }

    rewind(scoreboard);
#endif
}
