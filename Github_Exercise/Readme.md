
# GitHub Exercise



### Resources
1. Internal (Enterprise) GATech GitHub
    - *must* be connected to GATech VPN!
    - [url](https://github.gatech.edu/)
1. Public GitHub
    - [url](https://github.com/)
    - docs [here](https://docs.github.com/en)
    - get started [here](https://docs.github.com/en/get-started)
1. git Commands Cheat Sheet
    - printable PDF [here](https://education.github.com/git-cheat-sheet-education.pdf)
    - NOTE: be very, very cautious of the `git rebase` command!



### In-class Background
- Viewing our course-specific "Organization"
https://github.gatech.edu/compgenomics2025

- Understanding organization and username structures
    - repositories
    - README.md use as main landing page
    - Releases (or release versions) and semantic versioning [here](https://semver.org/)
    - commit messages and history



### In-class Exercise
1. Confirm you have git installed/available
`which git`
    - If that doesn't print out a path with `git` in it, such as `/usr/bin/git`, you cannot proceed until you have `git` installed
`git --help`
`git --version`
1. Login to the GATech VPN service, which requires:
    - username (e.g., cgulvik6)
    - same password used to log into email and Canvas
    - push or phone 2-factor authentication (e.g., a push to your phone Duo Mobile app)

1. Use web browser to view [the class org page](https://github.gatech.edu/compgenomics2025)

1. Go into the specific "extra-learning-resources" repo

1. Click the green box "Code" to see HTTPS and GIT urls
    - setup SSH if you haven't already [here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
    - The main steps involved are:
        1. confirm you don't have one and might not realize it
        1. create a new SSH key for your laptop (usually stored in `~/.ssh`)
        1. add the **PUBLIC** SSH key (e.g., `~/.ssh/id_rsa.pub`) to your GATech Enterprise GitHub account with the WebGUI [here](https://github.gatech.edu/settings/keys)

1. Clone the respository to your laptop environment (HTTPS username/password -vs- SSH passwordless authentication)
`git clone git@github.gatech.edu:compgenomics2025/extra-learning-resources.git`

1. Open the README.md file on your laptop in a text editor such as VS Code. I highly recommend trying VS Code for this course! You can get it [here](https://code.visualstudio.com/).

1. First look at the text itself, then view it as a MarkDown format



### Homework Exercise
This exercise is meant to confirm you're able to contribute to future projects in the course. Regardless of your skill level in `git`, this exact repo must be created for this homework assignment.

1. Create new "public" repository (WebGUI), named **my-test-repo**
[url](https://github.gatech.edu/new)

1. Clone the respository to your laptop environment (HTTPS username/password -vs- SSH passwordless authentication). Replace "$USER" with your gatech username (e.g., cgulvik6)
`git clone git@github.gatech.edu:$USER/my-test-repo.git $HOME/my-test-repo`

1. Create new README.md file inside of the newly cloned (empty) repository
```
cd ~/my-test-repo
touch README.md
```

4. Stage addition of the new file on your laptop
`git add README.md`

5. Add a meaningful message to your addition(s) and/or change(s)
`git commit -m 'new file created with content testing headers, bullet points, and URLs'`

6. Push the staged file to the github page
`git push origin main`

7. Verify you've added a the file to the website, and create a new text file to submit to Canvas with the URL to that repository for web viewing. It should only be 1 line and have no extra spaces, just the URL to the webpage (e.g., "https://github.gatech.edu/compgenomics2025/extra-learning-resources" would be
`echo 'https://github.gatech.edu/compgenomics2025/extra-learning-resources' > my-test-repo.txt`)

8. Gunzip compress the file
`gzip my-test-repo.txt`

9. Verify the file exists and is non-empty size
`ls -lh my-test-repo.txt.gz`

10. Confirm the content is your repo before submitting
`zcat my-test-repo.txt.gz`



### Homework Submission
Submit (1) file to Canvas containing your repository described above as 'my-test-repo.txt.gz'. Note: plaintext .txt and other compressed formats are not acceptable.

1. 10% grade:  Account Username Visible
1. 20% grade:  Filename is 'my-test-repo.txt.gz'
1. 20% grade:  File Commit contains a message
1. 50% grade:  Repository name is 'my-test-repo'
