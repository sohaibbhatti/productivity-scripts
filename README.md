productivity-scripts
====================

Scripts created and used by me for automation of repetitive tasks

# Git

## commit-msg(prepending pivotal story ids to commit messages)

A git for pivotal tracker integration. Pivotal tracker has this functionality that if configured, allows commits
to appear as comments in the story. this is acheived by appending `[#Pivotal_id]` to the commit message.

This reads the Pivotal story id from the branch name where it is defined and appends it to the start of every message.

### Update
 * Fixed a bug leading to empty commits whenever verbose commits belonging to pivotal branches were left empty. 

### Instructions

1. Copy this file and paste it into the `.git/hooks` folder of the current project.
2. While in the `.git/hooks` folder, enter the following command `chmod u+x commit-msg`
3. Congrats you're set!

Branches can now be created with the formats below and once commit messages are entered, the pivotal story id will be
prepended to the messages in an automated fashion.

```
git branch st{pivotal_story_id}_commit_description_here
git branch feature/st{pivotal_story_id}_commit_description_here
git branch hotfix/st{pivotal_story_id}_commit_description_here
```

# Tmux

## Configuration File for custom bindings

The default bindings of tmux aren't the easiest to learn. These
configurations make recalling commands a whole lot trivial. Relevant
comments added in the file


Credit: Brian P. Hogan -> Highly recommend his book!

### Instructions

1. Copy the .tmux.conf file to ~/.tmux.conf location
2. You're set!

# MySql

## SpeedDump

Automated for my primary work which involves loading database dumps of all the theaters, movies and showtimes in U.S.A.
This equates to the dump being a size of around a gig. Tweaks mentioned by [James Smith](http://loopj.com/2009/07/06/fast-mysql-backup-restore/)
are first applied. Then the database dump is actually loaded.

### Instructions

1. As a prerequisite, it is important for [Thor](https://github.com/wycats/thor) to be installed.
2. Download the file and place where ever convenient.
3. invoke_before_hook and invoke_after_hook can be overrided for custom
   functionality
4. Use the script!

```
  thor speed_dump:load_dump sql_dump.sql -u user -p password -d database
```
