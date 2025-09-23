---
title: "How_To_Organize_Data"
author: "Erica Robertson"
date: "2025-09-23"
output: html_document
---

# Introduction

How to structure project files is a pretty personal thing, but it took me a long time (3 years!) to settle on a good approach. It was something I hadn't thought much about coming into grad school and was complicated by not knowing enough to fully plan out (or even start to guess) what my workflow/methodology was going to look like. Also, it takes extra work and planning and intentional which can be hard to muster. But, that was before I realized the benefits of writing not only reproducible code, but organizing files so that they make sense. Now that I know, I enthusiastically invest time into improving these aspects of my project. So, why should you care?

## ***For You***

Consistency between projects and organized code is like having a tidy desk or room where you know where everything is. It's not only going to save time when you inevitably have to go back and figure out what you did but it will also make thinking through the whole process of a project that much easier. A great example of this is my first chapter work.

When I started, I had no real organization system. I had many versions of "GCRF_master", and which one was the "master" was anything but clear. I couldn't keep track of what samples I had efficiently, regularly had embarrassing moments where I couldn't answer simple questions like "what's you sample size?" "what filters did you run?" "can you show me X figure?". You'll impress the heck out of your PI if you can come in from the beginning having everything under control, and it will save you a lot of time and stress. Another part of this is that, most likely, you will have to redo some analyses for your dissertation work. For me, I had to do my Chapter 1 analyses 4 separate times. This is challenging mentally, and made even harder by not being totally sure what you did the first time around and how to reproduce that or improve it. For me, having my code broken down by steps with running notes and details of what I was thinking and what the results meant was a huge step is feeling like I had control over my research and a fully grasp of what my project was about and what I was trying to do. Also, when I had to go to other projects and apply the same packages or needed similar figures, it was so much easier to find where I'd already figured it out and just copy and adjust the code rather than starting from scratch every time!

## ***For Others***

A major goal of a graduate program is to do original research and share those results. A key part of being able to share your results is to also shoot for reproducibility. Organized code is essential for this. You want someone to be able to open up your project and understand exactly what you did, why you made decisions, and how they can do it themselves, and you want this to be an easy process. This is important not only for collaborations, helping others who are trying to run similar analyses, but it's actually often a requirement for publishing. When you submit a manuscript you don't just give them your figures and pdf file of the paper, you also upload the code you used to get the results and all of the files associated with a project. You can save yourself a lot of time, and your reviewers a lot of stress (which might make them less inclined to let you publish!) by keeping your code organized from the beginning.

# Getting Started

Like I said before, how you chose to organize your code is a personal decision (and process). That being said, I can make some recommendations of things to think about when deciding on a process and provide some examples of structures you might try. The first step in deciding how to organize files is considering the goals of your project and code and considering who will be looking at it (your audience).

## Consideration of Goals

For most of us, regardless of what your research is one or what kind of code you're writing, you have the following goals or steps in your process of doing science.

1.  You work with some sort of data

2.  You will modify the data to meet your needs

3.  You will analyze the data and make conclusions

4.  You will create representations of such conclusions (charts, figures, images, etc)

5.  You will share some or all of the above processes with others, whether by turning in an assignment for class, or publishing results with a conference or journal

To be effective for the last step, you need to consider your audience. Those people who are viewing your code might want to...

1.  Repeat and confirm your results and methodologies

2.  Perform their own analyses

3.  Use your source code to develop their own projects

4.  Better understand your results and figures

Thinking about how best to go through your goals while considering the potential needs of your audience is important when determining a consistent file organization system.

## Nothing is Set in Stone

An important point here is that, whatever file structure you come up with, it doesn't have to be set in stone. Needs of a particular project are going to vary, some methodologies might work better with a particular system, and you're likely to realize you need to adjust things as you go along. Your goal, especially when you start thinking about these kinds of things, is to come up with a general framework or principles to follow. As you get more experience and work on more projects your framework may evolve, will hopefully improve, and should always maintain flexibility.

# Best Practices for File Structures

There are some overarching ground rules to keep in mind before starting a project or considering file structure methods. They are:

1.  Do not modify your raw data manually, or even better, at all.\
    (Don’t give in to the temptation of opening a raw dataset in Excel and changing values.)

2.  Data manipulation should work like a conveyer belt: it stops at checkpoints. E.g., it gets modified/cleaned/analyzed, and then it moves on.

3.  Code of different quality (scratch work vs. compiled binaries) should be separated.

4.  Always have collaborators in mind, even if there is a 0% chance of getting collaborators. Work towards shareable code. Have public awareness. In a way, imagine if your code were to be released on GitHub *right now*.

5.  Use relative file paths, not absolute paths, to facilitate shareability.

6.  **Consistency (within your project) is key.**

## Other things to think about

When breaking down file structures, each folder should contain files with similar functionality or purposes. For example, you might have a raw_data folder that has the direct outputs of your analyses, then a finalized_data folder where you have the cleaned and modified data that will go into the next step of a workflow or will be used to create figures, etc.

Always put everything into scripts to ensure repeatability, even if it's something quick and easy to do in the command line. This might seem tedious but it's an important part of keeping track of everything. So, don't go into your csv file and manually change the heading or file name or whatever. Make a small R script that does that, and name that script something informative.

One thing that can be useful for keeping track of things is a lab notebook. This can either be an actual notebook you write in or a separate documentation file that you update as you go. This is a cool thing (that I wish I did more consistently) that can help you keep track of errors and solutions, steps, script orders, versions of things, etc. This can help a lot when cleaning up the final versions of code, and referring back when trying to understand what exactly you did.

Always keep results separate from everything else! This is often the thing you will want the fastest access to. Image you're in a meeting and your PI asks for a figure. You've made that figure, and because you were smart you put it in a specific results folder under the type of analyses that generated that results (for example). You can quickly pull it up without the awkward silence of trying to go through your files and remember which "test_plot.png" is the right one.

Some people feel very strongly about including date info in file names. I'm not one of those people. Every file you generate is going to have date data associated with it as soon as you save. Also, if you're very well behaved and use a version control method like github, you can always go back to older versions of things if needed. For these reasons I focus on having informative file names that don't include dates but might include version information (like "all_snp_PCA_v1.png").

# Choose a Structure That Matches the Project

The basic components of a file structure are as follows:

1.  a unique main folder for the project (like "Chapter_1")

2.  some form of code

3.  some form of data

4.  a readme document with important information about the project

## A starting point

Figure out your base structure. You want a root directory that contains everything for that project. You want to think through how big this project is going to be (a small project might not need a super complex file structure plan). Assess the easiest way to access the data and code. It it chronological? Is it by analysis type? Is it why question? Is it all three??

## Naming files

Please, please, please don't include spaces in your file names!!!! I cannot stress this enough. This is super important as your computer cannot interpret spaces easily and navigating and writing paths will become a pain in the behind if you have spaces. Plus, nothing gives away the fact that you don't know what you're doing faster than having spaces in file and folder names, and no one wants that.

So what can you do? A couple options:

-   Underscores (my favorite): raw_data, final_results, all_sample_map.png

-   camelCase: rawData, finalResults, allSampleMaps.png

-   Periods: raw.data, final.results, all.sample.map.png

-   Hyphen: raw-data, final-results, all-sample-map.png

-   A wild (but intentional) combination: BANS.6x.maf_0.05.SNP.above_4x.maxmiss\_.08.imputed4.1.vcf.gz

# Example Structures

The first three of these are taken directly from examples provided by <https://mitcommlab.mit.edu/broad/commkit/file-structure/>

## Almost Flat (super simple)

<pre>PROJECT/ ├── figures/ \<- plots.m saves figures in here ├── main.m \<- does something fancy, calls plots.m ├── plots.m \<- make presentation figures ├── raw2wind.m \<- script to clean .csv data to .mat ├── readme.txt ├── windSpeed_MITGreenBuilding.mat \<- cleaned data ├── weatherStation_MITGreenBuilding_2019_07_01.csv \<- raw data ├── weatherStation_MITGreenBuilding_2019_07_02.csv ├── weatherStation_MITGreenBuilding_2019_07_03.csv ├── weatherStation_MITGreenBuilding_2019_07_04.csv ├── weatherStation_MITGreenBuilding_2019_07_05.csv ├── weatherStation_MITGreenBuilding_2019_07_06.csv └── weatherStation_MITGreenBuilding_2019_07_07.csv</pre>
