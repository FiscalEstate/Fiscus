## SYNCHRONIZATION WITH GITHUB
1) Open GitHub Desktop, click first on **Fetch origin** (which checks whether there are new changes in the online repository) and, if it appears, on **Pull origin** (which copies into your folder the new changes that have been found in the online repository).
2) Open the files you want to edit in Oxygen, work on it and than save the changes.
3) Open GitHub Desktop; click on **Fetch origin** (and on **Pull origin**); add in **Summary** a very short description of the changes made (or leave the default description); click on **Commit to main** and then on top on **Push origin** (which sends your changes to the online repository)

Note: it is highly recommended to click on **Fetch origin** (+ **Pull origin**) from time to time also while editing.

## GITHUB DESKTOP MESSAGES GUIDE

1) If you are doing **Commit** + **Push origin** (after having done **Fetch origin** + **Pull origin**) but your changes affect one or more files which has been changed also by someone else, you will see the message **Unable to pull when changes are present on your branch**, with the options 'Close' or **Stash changes and continue**. Click on **Stash changes and continue**, which sets your changes aside, and then continue with **Fetch** + **Pull**.

   <img width="612" height="260" alt="01" src="https://github.com/user-attachments/assets/345803cc-d6f2-487d-b95d-75e4e3ecf531" />

   Then, by clicking on bottom-right on **Stashed changes**, you are given the option to either **Discard** or **Restore** the changes that you set aside, showing the file(s) with both yours and other people’s changes.

   <img width="951" height="788" alt="02" src="https://github.com/user-attachments/assets/35c3119b-87e9-4f11-b8e2-193ca085c6d0" />

   1a) If you and the other editor(s) have changed different parts of the same file, in the file shown in 'Stashed changes' you will see that these changes are compatible, and you can click on **Restore** and safely continue with Commit (see screenshot above).

   1b) If you and the other editor(s) have edited the file in the same exact place/lines, instead, in the file shown in 'Stashed changes' you will see in every edited place this '<<<<<< HEAD/Updated upstream/…', followed by the most recent version of this text part, followed by '======', followed by our older version of this text part, followed by '>>>>>>> Stashed changes/…' (see screenshot below). In this case, the most practical approach is to click on **Discard**, reopen the file in Oxygen and re-make the discarded changes manually (if you are used to do Fetch+Pull and Commit+Push rather often, these changes will be probably very few). Otherwise, you can choose to click on 'Restore', removing then manually in Oxygen the lines starting with  <<<< / ==== / >>>> that appeared in the file, and removing manually the version of the text that should not be kept. Once the conflict is resolved, you can continue with ‘Commit’.

   <img width="1222" height="657" alt="03" src="https://github.com/user-attachments/assets/f373cbb5-677c-4b5f-b53a-a8fa8e7f1115" />

2) If you are doing 'Commit' + 'Push origin' but you forgot to do first 'Fetch origin' + 'Pull origin', you will se the harmless message **Newer commits to remote** reminding you to do so, and offering you the two options 'Cancel' or **Fetch**. Click on ‘Fetch’ (and then, if necessary, on ‘Pull origin’).

   <img width="484" height="166" alt="04" src="https://github.com/user-attachments/assets/47466ae8-8fcb-431f-af38-3abbd445cfb5" />

   2a) If the changes made by others affect other files, everything is fine. You can continue safely with Commit. Please note that in this case the History will include also an extra commit, called "Merge branch 'main' of https://github.com/.../…" (which is ok!).

   2b) If the changes made by others affect one or more files that you edited, you will see the message **Resolve conflicts before Merge** and you will need then to click 'Open in editor' and edit the file manually in Oxygen. REMEMBER: THIS CASE CAN BE ALWAYS AVOIDED BY REMEMBERING TO DO FETCH ORIGIN + PULL ORIGIN BEFORE EACH COMMIT!

   <img width="396" height="213" alt="05" src="https://github.com/user-attachments/assets/11b29302-6528-4d74-b493-a5a7b44dbcad" />

   Once the conflict has been resolved manually in Oxygen, this message will appear, in which you can now click on **Continue merge** and continue then with commit:

   <img width="399" height="211" alt="06" src="https://github.com/user-attachments/assets/2556b528-3180-4425-a78d-7028383648e6" />

## REMOVE AND RE-CLONE A REPOSITORY

If more complex conflicts or other internal GitHub errors happen, it may be often easier to remove the repository entirely from your GitHub Desktop and then re-clone it, especially if you have few local changes that have not been pushed to the online repository. To do so:

- First copy manually elsewhere on your computer the files on which you worked, to ensure that you will not loose the un-pushed changes
- In GitHub Desktop click on top-left on ‘Current Repository XXX’
- On the side panel that appears, click on the name of the repository
- In the dropdown menu that appears, click on ‘Remove…’
- In the popup that appears, select ‘Also move this repository to Trash’ and then click on ‘Remove’
- Click on ‘Add’ / ‘Clone repository’ (this option can appear in different areas of GitHub Desktop interface)
- In the popup that appears, open the ‘GitHub.com’ tab and select your repository, specifying as ‘Local path’ the place on your computer where you want to save the repository, and then click on ‘Clone’

<img width="1102" height="385" alt="07" src="https://github.com/user-attachments/assets/7aa89a66-d7b3-49fc-9def-e647342393bc" />

then

<img width="1104" height="672" alt="08" src="https://github.com/user-attachments/assets/5e57ea50-8c3a-4ef5-922a-25ffc163fa62" />

then

<img width="630" height="298" alt="09" src="https://github.com/user-attachments/assets/e355a4a6-eb6f-49f4-8ad2-7cc94400155b" />

then

<img width="1054" height="493" alt="10" src="https://github.com/user-attachments/assets/ebcabdaf-3717-46c0-a771-48db84f43769" />

then

<img width="585" height="528" alt="11" src="https://github.com/user-attachments/assets/82b29cc5-9b20-4d30-b5ae-64c4f6796f3b" />

