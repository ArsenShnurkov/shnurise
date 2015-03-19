<<<<<<< HEAD
shnurise
========

ebuilds for programs for use with gentoo/funtoo/calculate/exherbo and other source-based linux distributions

how to use
==========

add the following line to the /etc/layman/layman.cfg under option
    
    overlays :
    https://raw.githubusercontent.com/ArsenShnurkov/shnurise/master/shnurise-overlay-metadata-for-layman.xml
   
check that /etc/portage/make.conf (or one of files included with "source" bash command) contains line
    
    source "/var/lib/layman/make.conf"

to download overlay description execute
    
    layman -L

to add and download overlay execute
    
    layman -a shnurise

to search "mypad" package (-o is for overlays, -p is for portage tree, no option is for installed packages?)
    
    equery list mypad -o

to unmask package execute
    
    emerge --autounmask-package =mypad-9999
    etc-update

press -5

to install "mypad" package execute

    emerge -av =mypad-9999
    
later to update overlays you will need to execute (in cron?)

    layman -S



how to develop
==============

    cd /var/lib/layman
    git clone https://github.com/ArsenShnurkov/shnurise.git shnurise
    cd shnurise
    monodevelop ./portage-ebuilds.mdw

Edit it with Monodevelop 5.6 or later
=======
# Git Extensions

WARNING: Repository rewritten on 2014-08-24 to reduce its size. Please clone it again. |
-----------
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/gitextensions/gitextensions?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Issue Stats](http://www.issuestats.com/github/gitextensions/gitextensions/badge/pr?style=flat)](http://www.issuestats.com/github/gitextensions/gitextensions) [![Issue Stats](http://www.issuestats.com/github/gitextensions/gitextensions/badge/issue?style=flat)](http://www.issuestats.com/github/gitextensions/gitextensions) [![SourceForge](https://img.shields.io/sourceforge/dm/gitextensions.svg)](https://sourceforge.net/projects/gitextensions/)


## Introduction

GitExtensions is a shell extension, a Visual Studio 2008 / 2010 / 2012 / 2013 plugin and a standalone Git repository tool.

## Current status

Build status: master [![Status](http://teamcity.codebetter.com/app/rest/builds/buildType:\(id:GitExtensions_Master\)/statusIcon)](http://teamcity.codebetter.com/viewType.html?buildTypeId=GitExtensions_Master)

Mono Build status: master
[![Build Status](https://travis-ci.org/gitextensions/gitextensions.svg?branch=master)](https://travis-ci.org/gitextensions/gitextensions)

Translation: [![Transifex](https://ds0k0en9abmn1.cloudfront.net/static/charts/images/tx-logo-micro.646b0065fce6.png)](https://www.transifex.com/projects/p/git-extensions/)

[![Transifex Stats](https://www.transifex.com/projects/p/git-extensions/resource/ui-master/chart/image_png)](https://www.transifex.com/projects/p/git-extensions/)

The [build](http://teamcity.codebetter.com/project.html?projectId=GitExtensions&branch_GitExtensions=__all_branches__) is generously hosted and run on the [CodeBetter TeamCity](http://codebetter.com/codebetter-ci/) infrastructure.

## Links

* Download page: [https://sourceforge.net/projects/gitextensions/](https://sourceforge.net/projects/gitextensions/)
* Online manual: [https://git-extensions-documentation.readthedocs.org/en/latest/](https://git-extensions-documentation.readthedocs.org/en/latest/)
* Issue tracker: [http://github.com/gitextensions/gitextensions/issues](http://github.com/gitextensions/gitextensions/issues)
* Mailing list: [http://groups.google.com/group/gitextensions](http://groups.google.com/group/gitextensions)
* ChangeLog: [ChangeLog.md](GitUI/Resources/ChangeLog.md)
* Source code: [http://github.com/gitextensions/gitextensions](http://github.com/gitextensions/gitextensions)
* Wiki: [https://github.com/gitextensions/gitextensions/wiki](https://github.com/gitextensions/gitextensions/wiki)
>>>>>>> 0f33be33cfcc87a61ba6fcb5c09b9e84e91f3aed
