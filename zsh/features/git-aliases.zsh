
require_once "$ZSH_SCRIPTING_DIRECTORY/features/zinit.zsh"

zinit snippet OMZP::git

function git-set-me-xpro() {
    git config user.name "Petr Fusek"
    git config user.email petr.fusek@xproduction.cz
}

function git-set-me-gmail() {
    git config user.name "Petr Fusek"
    git config user.email petr.fusek97@gmail.com
}

function git-last-commit-rename() {
    # glcr - Git Last Commit Rename
    # A utility to amend the last git commit message using Visual Studio Code

    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Create a temporary file for editing the commit message
    TEMP_FILE=$(mktemp)

    # Get the last commit message and put it in the temporary file, commented out
    echo "# Current commit message (commented out for reference):" > "$TEMP_FILE"
    git log -1 --pretty=%B | sed 's/^/# /' >> "$TEMP_FILE"
    echo -e "\n# Enter your new commit message above this line." >> "$TEMP_FILE"
    echo "# Lines starting with '#' will be ignored." >> "$TEMP_FILE"

    # Open VSCode to edit the file and wait for it to close
    code --wait "$TEMP_FILE"

    # Check if the file has content other than comments and empty lines
    NON_COMMENT_LINES=$(grep -v "^#" "$TEMP_FILE" | grep -v "^$" | wc -l)
    if [ "$NON_COMMENT_LINES" -eq 0 ]; then
        echo "Abort: No new commit message provided"
        rm "$TEMP_FILE"
        return 1
    fi

    # Extract only the non-comment lines to use as the new commit message
    grep -v "^#" "$TEMP_FILE" > "${TEMP_FILE}.new"

    # Amend the commit with the new message
    git commit --amend -F "${TEMP_FILE}.new"
    echo "Commit message updated successfully"

    # Clean up temporary files
    rm "$TEMP_FILE" "${TEMP_FILE}.new"
}

alias glcr=git-last-commit-rename

function generate-git-alias-list() {
    local green='\033[0;32m'
    local blue='\033[0;34m'
    local reset='\033[0m'

    alias | grep -E '^g[a-z]' | grep 'git' | while read -r line; do
        local alias_name=$(echo "$line" | cut -d'=' -f1)
        local alias_cmd=$(echo "$line" | cut -d'=' -f2- | tr -d "'")
        printf "${green}%s${reset} -> ${blue}%s${reset}\n" "$alias_name" "$alias_cmd"
    done
}

function gah_raw() {
    local green='\033[0;32m'
    local blue='\033[0;34m'
    local reset='\033[0m'

    printf "${green}ga${reset} -> ${blue}git add${reset} -> Add file contents to the index\n"
    printf "${green}gaa${reset} -> ${blue}git add --all${reset} -> Add all changes to the index\n"
    printf "${green}gam${reset} -> ${blue}git am${reset} -> Apply a series of patches from a mailbox\n"
    printf "${green}gama${reset} -> ${blue}git am --abort${reset} -> Abort the current patch application\n"
    printf "${green}gamc${reset} -> ${blue}git am --continue${reset} -> Continue applying patches after resolving conflicts\n"
    printf "${green}gams${reset} -> ${blue}git am --skip${reset} -> Skip the current patch\n"
    printf "${green}gamscp${reset} -> ${blue}git am --show-current-patch${reset} -> Show the current patch being applied\n"
    printf "${green}gap${reset} -> ${blue}git apply${reset} -> Apply a patch to files and/or the index\n"
    printf "${green}gapa${reset} -> ${blue}git add --patch${reset} -> Interactively add changes to the index\n"
    printf "${green}gapt${reset} -> ${blue}git apply --3way${reset} -> Attempt 3-way merge if a patch does not apply\n"
    printf "${green}gau${reset} -> ${blue}git add --update${reset} -> Update the index with changes from the working tree\n"
    printf "${green}gav${reset} -> ${blue}git add --verbose${reset} -> Be verbose about adding files\n"
    printf "${green}gb${reset} -> ${blue}git branch${reset} -> List, create, or delete branches\n"
    printf "${green}gbD${reset} -> ${blue}git branch --delete --force${reset} -> Force delete a branch\n"
    printf "${green}gba${reset} -> ${blue}git branch --all${reset} -> List all branches\n"
    printf "${green}gbd${reset} -> ${blue}git branch --delete${reset} -> Delete a branch\n"
    printf "${green}gbg${reset} -> ${blue}LANG=C git branch -vv | grep \": gone\]\"${reset} -> List branches with gone upstream\n"
    printf "${green}gbgD${reset} -> ${blue}LANG=C git branch --no-color -vv | grep \": gone\]\" | cut -c 3- | awk \{print \$1\} | xargs git branch -D${reset} -> Force delete branches with gone upstream\n"
    printf "${green}gbgd${reset} -> ${blue}LANG=C git branch --no-color -vv | grep \": gone\]\" | cut -c 3- | awk \{print \$1\} | xargs git branch -d${reset} -> Delete branches with gone upstream\n"
    printf "${green}gbl${reset} -> ${blue}git blame -w${reset} -> Show what revision and author last modified each line of a file\n"
    printf "${green}gbm${reset} -> ${blue}git branch --move${reset} -> Move/rename a branch\n"
    printf "${green}gbnm${reset} -> ${blue}git branch --no-merged${reset} -> List branches not yet merged\n"
    printf "${green}gbr${reset} -> ${blue}git branch --remote${reset} -> List remote branches\n"
    printf "${green}gbs${reset} -> ${blue}git bisect${reset} -> Use binary search to find the commit that introduced a bug\n"
    printf "${green}gbsb${reset} -> ${blue}git bisect bad${reset} -> Mark the current state as bad\n"
    printf "${green}gbsg${reset} -> ${blue}git bisect good${reset} -> Mark the current state as good\n"
    printf "${green}gbsn${reset} -> ${blue}git bisect new${reset} -> Mark the current state as new\n"
    printf "${green}gbso${reset} -> ${blue}git bisect old${reset} -> Mark the current state as old\n"
    printf "${green}gbsr${reset} -> ${blue}git bisect reset${reset} -> Reset bisect state\n"
    printf "${green}gbss${reset} -> ${blue}git bisect start${reset} -> Start bisect session\n"
    printf "${green}gc${reset} -> ${blue}git commit --verbose${reset} -> Record changes to the repository\n"
    printf "${green}gcB${reset} -> ${blue}git checkout -B${reset} -> Create and checkout a new branch\n"
    printf "${green}gca${reset} -> ${blue}git commit --verbose --all${reset} -> Commit all changes\n"
    printf "${green}gcam${reset} -> ${blue}git commit --all --message${reset} -> Commit all changes with a message\n"
    printf "${green}gcas${reset} -> ${blue}git commit --all --signoff${reset} -> Commit all changes with signoff\n"
    printf "${green}gcasm${reset} -> ${blue}git commit --all --signoff --message${reset} -> Commit all changes with signoff and message\n"
    printf "${green}gcb${reset} -> ${blue}git checkout -b${reset} -> Create and checkout a new branch\n"
    printf "${green}gcd${reset} -> ${blue}git checkout \$(git_develop_branch)${reset} -> Checkout the develop branch\n"
    printf "${green}gcf${reset} -> ${blue}git config --list${reset} -> List all configuration settings\n"
    printf "${green}gcl${reset} -> ${blue}git clone --recurse-submodules${reset} -> Clone a repository and its submodules\n"
    printf "${green}gclean${reset} -> ${blue}git clean --interactive -d${reset} -> Remove untracked files\n"
    printf "${green}gclf${reset} -> ${blue}git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules${reset} -> Clone a repository with shallow submodules\n"
    printf "${green}gcm${reset} -> ${blue}git checkout \$(git_main_branch)${reset} -> Checkout the main branch\n"
    printf "${green}gcmsg${reset} -> ${blue}git commit --message${reset} -> Commit with a message\n"
    printf "${green}gcn${reset} -> ${blue}git commit --verbose --no-edit${reset} -> Commit without editing the message\n"
    printf "${green}gco${reset} -> ${blue}git checkout${reset} -> Switch branches or restore working tree files\n"
    printf "${green}gcor${reset} -> ${blue}git checkout --recurse-submodules${reset} -> Checkout with submodules\n"
    printf "${green}gcount${reset} -> ${blue}git shortlog --summary --numbered${reset} -> Summarize 'git log' output\n"
    printf "${green}gcp${reset} -> ${blue}git cherry-pick${reset} -> Apply the changes introduced by some existing commits\n"
    printf "${green}gcpa${reset} -> ${blue}git cherry-pick --abort${reset} -> Abort the current cherry-pick\n"
    printf "${green}gcpc${reset} -> ${blue}git cherry-pick --continue${reset} -> Continue cherry-pick after resolving conflicts\n"
    printf "${green}gcs${reset} -> ${blue}git commit --gpg-sign${reset} -> Commit with GPG signature\n"
    printf "${green}gcsm${reset} -> ${blue}git commit --signoff --message${reset} -> Commit with signoff and message\n"
    printf "${green}gcss${reset} -> ${blue}git commit --gpg-sign --signoff${reset} -> Commit with GPG signature and signoff\n"
    printf "${green}gcssm${reset} -> ${blue}git commit --gpg-sign --signoff --message${reset} -> Commit with GPG signature, signoff, and message\n"
    printf "${green}gd${reset} -> ${blue}git diff${reset} -> Show changes between commits, commit and working tree, etc\n"
    printf "${green}gdca${reset} -> ${blue}git diff --cached${reset} -> Show changes between index and last commit\n"
    printf "${green}gdct${reset} -> ${blue}git describe --tags \$(git rev-list --tags --max-count=1)${reset} -> Show the most recent tag on the current branch\n"
    printf "${green}gdcw${reset} -> ${blue}git diff --cached --word-diff${reset} -> Show changes between index and last commit with word diff\n"
    printf "${green}gds${reset} -> ${blue}git diff --staged${reset} -> Show changes between staged changes and last commit\n"
    printf "${green}gdt${reset} -> ${blue}git diff-tree --no-commit-id --name-only -r${reset} -> Show changes between trees\n"
    printf "${green}gdup${reset} -> ${blue}git diff @{upstream}${reset} -> Show changes between working tree and upstream\n"
    printf "${green}gdw${reset} -> ${blue}git diff --word-diff${reset} -> Show changes between commits with word diff\n"
    printf "${green}gf${reset} -> ${blue}git fetch${reset} -> Download objects and refs from another repository\n"
    printf "${green}gfa${reset} -> ${blue}git fetch --all --tags --prune --jobs=10${reset} -> Fetch all remotes with tags and prune\n"
    printf "${green}gfg${reset} -> ${blue}git ls-files | grep${reset} -> List files and grep\n"
    printf "${green}gfo${reset} -> ${blue}git fetch origin${reset} -> Fetch from origin\n"
    printf "${green}gg${reset} -> ${blue}git gui citool${reset} -> Start git GUI commit tool\n"
    printf "${green}gga${reset} -> ${blue}git gui citool --amend${reset} -> Start git GUI commit tool to amend\n"
    printf "${green}ggpull${reset} -> ${blue}git pull origin \"\$(git_current_branch)\"${reset} -> Pull from origin current branch\n"
    printf "${green}ggpush${reset} -> ${blue}git push origin \"\$(git_current_branch)\"${reset} -> Push to origin current branch\n"
    printf "${green}ggsup${reset} -> ${blue}git branch --set-upstream-to=origin/\$(git_current_branch)${reset} -> Set upstream for current branch\n"
    printf "${green}ghh${reset} -> ${blue}git help${reset} -> Display help information about git\n"
    printf "${green}gignore${reset} -> ${blue}git update-index --assume-unchanged${reset} -> Ignore changes to a file\n"
    printf "${green}gignored${reset} -> ${blue}git ls-files -v | grep \"^[[:lower:]]\"${reset} -> List ignored files\n"
    printf "${green}git-svn-dcommit-push${reset} -> ${blue}git svn dcommit && git push github \$(git_main_branch):svntrunk${reset} -> Commit to SVN and push to GitHub\n"
    printf "${green}gk${reset} -> ${blue}\\gitk --all --branches &!${reset} -> Start gitk GUI\n"
    printf "${green}gke${reset} -> ${blue}\\gitk --all \$(git log --walk-reflogs --pretty=%h) &!${reset} -> Start gitk GUI with reflogs\n"
    printf "${green}gl${reset} -> ${blue}git pull${reset} -> Fetch from and integrate with another repository or a local branch\n"
    printf "${green}glg${reset} -> ${blue}git log --stat${reset} -> Show commit logs with stats\n"
    printf "${green}glgg${reset} -> ${blue}git log --graph${reset} -> Show commit logs with graph\n"
    printf "${green}glgga${reset} -> ${blue}git log --graph --decorate --all${reset} -> Show commit logs with graph and all refs\n"
    printf "${green}glgm${reset} -> ${blue}git log --graph --max-count=10${reset} -> Show commit logs with graph and limit to 10\n"
    printf "${green}glgp${reset} -> ${blue}git log --stat --patch${reset} -> Show commit logs with stats and patch\n"
    printf "${green}glo${reset} -> ${blue}git log --oneline --decorate${reset} -> Show commit logs in one line with decorations\n"
    printf "${green}glod${reset} -> ${blue}git log --graph --pretty=\"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset\"${reset} -> Show commit logs with graph and pretty format\n"
    printf "${green}glods${reset} -> ${blue}git log --graph --pretty=\"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset\" --date=short${reset} -> Show commit logs with graph, pretty format, and short date\n"
    printf "${green}glog${reset} -> ${blue}git log --oneline --decorate --graph${reset} -> Show commit logs in one line with decorations and graph\n"
    printf "${green}gloga${reset} -> ${blue}git log --oneline --decorate --graph --all${reset} -> Show commit logs in one line with decorations, graph, and all refs\n"
    printf "${green}glol${reset} -> ${blue}git log --graph --pretty=\"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset\"${reset} -> Show commit logs with graph and pretty format\n"
    printf "${green}glola${reset} -> ${blue}git log --graph --pretty=\"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset\" --all${reset} -> Show commit logs with graph, pretty format, and all refs\n"
    printf "${green}glols${reset} -> ${blue}git log --graph --pretty=\"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset\" --stat${reset} -> Show commit logs with graph, pretty format, and stats\n"
    printf "${green}glp${reset} -> ${blue}_git_log_prettily${reset} -> Show commit logs prettily\n"
    printf "${green}gluc${reset} -> ${blue}git pull upstream \$(git_current_branch)${reset} -> Pull from upstream current branch\n"
    printf "${green}glum${reset} -> ${blue}git pull upstream \$(git_main_branch)${reset} -> Pull from upstream main branch\n"
    printf "${green}gm${reset} -> ${blue}git merge${reset} -> Join two or more development histories together\n"
    printf "${green}gma${reset} -> ${blue}git merge --abort${reset} -> Abort the current merge\n"
    printf "${green}gmc${reset} -> ${blue}git merge --continue${reset} -> Continue the current merge\n"
    printf "${green}gmff${reset} -> ${blue}git merge --ff-only${reset} -> Merge with fast-forward only\n"
    printf "${green}gmom${reset} -> ${blue}git merge origin/\$(git_main_branch)${reset} -> Merge origin main branch\n"
    printf "${green}gms${reset} -> ${blue}git merge --squash${reset} -> Merge with squash\n"
    printf "${green}gmtl${reset} -> ${blue}git mergetool --no-prompt${reset} -> Run merge conflict resolution tools\n"
    printf "${green}gmtlvim${reset} -> ${blue}git mergetool --no-prompt --tool=vimdiff${reset} -> Run merge conflict resolution tools with vimdiff\n"
    printf "${green}gmum${reset} -> ${blue}git merge upstream/\$(git_main_branch)${reset} -> Merge upstream main branch\n"
    printf "${green}gp${reset} -> ${blue}git push${reset} -> Update remote refs along with associated objects\n"
    printf "${green}gpd${reset} -> ${blue}git push --dry-run${reset} -> Dry run push\n"
    printf "${green}gpf${reset} -> ${blue}git push --force-with-lease --force-if-includes${reset} -> Force push with lease and includes\n"
    printf "${green}gpoat${reset} -> ${blue}git push origin --all && git push origin --tags${reset} -> Push all branches and tags to origin\n"
    printf "${green}gpod${reset} -> ${blue}git push origin --delete${reset} -> Delete a branch on origin\n"
    printf "${green}gpr${reset} -> ${blue}git pull --rebase${reset} -> Rebase the current branch on top of the upstream branch\n"
    printf "${green}gpra${reset} -> ${blue}git pull --rebase --autostash${reset} -> Rebase with autostash\n"
    printf "${green}gprav${reset} -> ${blue}git pull --rebase --autostash -v${reset} -> Rebase with autostash and verbose\n"
    printf "${green}gpristine${reset} -> ${blue}git reset --hard && git clean --force -dfx${reset} -> Reset and clean the working directory\n"
    printf "${green}gprom${reset} -> ${blue}git pull --rebase origin \$(git_main_branch)${reset} -> Rebase on top of the main branch from origin\n"
    printf "${green}gpromi${reset} -> ${blue}git pull --rebase=interactive origin \$(git_main_branch)${reset} -> Interactive rebase on top of the main branch from origin\n"
    printf "${green}gprum${reset} -> ${blue}git pull --rebase upstream \$(git_main_branch)${reset} -> Rebase on top of the main branch from upstream\n"
    printf "${green}gprumi${reset} -> ${blue}git pull --rebase=interactive upstream \$(git_main_branch)${reset} -> Interactive rebase on top of the main branch from upstream\n"
    printf "${green}gprv${reset} -> ${blue}git pull --rebase -v${reset} -> Rebase with verbose\n"
    printf "${green}gpsup${reset} -> ${blue}git push --set-upstream origin \$(git_current_branch)${reset} -> Set upstream for the current branch and push\n"
    printf "${green}gpsupf${reset} -> ${blue}git push --set-upstream origin \$(git_current_branch) --force-with-lease --force-if-includes${reset} -> Set upstream and force push with lease and includes\n"
    printf "${green}gpu${reset} -> ${blue}git push upstream${reset} -> Push to upstream\n"
    printf "${green}gpv${reset} -> ${blue}git push --verbose${reset} -> Push with verbose\n"
    printf "${green}gr${reset} -> ${blue}git remote${reset} -> Manage set of tracked repositories\n"
    printf "${green}gra${reset} -> ${blue}git remote add${reset} -> Add a remote repository\n"
    printf "${green}grb${reset} -> ${blue}git rebase${reset} -> Reapply commits on top of another base tip\n"
    printf "${green}grba${reset} -> ${blue}git rebase --abort${reset} -> Abort the current rebase\n"
    printf "${green}grbc${reset} -> ${blue}git rebase --continue${reset} -> Continue the current rebase\n"
    printf "${green}grbd${reset} -> ${blue}git rebase \$(git_develop_branch)${reset} -> Rebase on top of the develop branch\n"
    printf "${green}grbi${reset} -> ${blue}git rebase --interactive${reset} -> Interactive rebase\n"
    printf "${green}grbm${reset} -> ${blue}git rebase \$(git_main_branch)${reset} -> Rebase on top of the main branch\n"
    printf "${green}grbo${reset} -> ${blue}git rebase --onto${reset} -> Rebase onto another branch\n"
    printf "${green}grbom${reset} -> ${blue}git rebase origin/\$(git_main_branch)${reset} -> Rebase on top of the main branch from origin\n"
    printf "${green}grbs${reset} -> ${blue}git rebase --skip${reset} -> Skip the current rebase\n"
    printf "${green}grbum${reset} -> ${blue}git rebase upstream/\$(git_main_branch)${reset} -> Rebase on top of the main branch from upstream\n"
    printf "${green}grev${reset} -> ${blue}git revert${reset} -> Revert some existing commits\n"
    printf "${green}greva${reset} -> ${blue}git revert --abort${reset} -> Abort the current revert\n"
    printf "${green}grevc${reset} -> ${blue}git revert --continue${reset} -> Continue the current revert\n"
    printf "${green}grf${reset} -> ${blue}git reflog${reset} -> Manage reflog information\n"
    printf "${green}grh${reset} -> ${blue}git reset${reset} -> Reset current HEAD to the specified state\n"
    printf "${green}grhh${reset} -> ${blue}git reset --hard${reset} -> Hard reset current HEAD\n"
    printf "${green}grhk${reset} -> ${blue}git reset --keep${reset} -> Keep changes in the working directory\n"
    printf "${green}grhs${reset} -> ${blue}git reset --soft${reset} -> Soft reset current HEAD\n"
    printf "${green}grm${reset} -> ${blue}git rm${reset} -> Remove files from the working tree and from the index\n"
    printf "${green}grmc${reset} -> ${blue}git rm --cached${reset} -> Remove files from the index only\n"
    printf "${green}grmv${reset} -> ${blue}git remote rename${reset} -> Rename a remote\n"
    printf "${green}groh${reset} -> ${blue}git reset origin/\$(git_current_branch) --hard${reset} -> Hard reset to the current branch from origin\n"
    printf "${green}grrm${reset} -> ${blue}git remote remove${reset} -> Remove a remote\n"
    printf "${green}grs${reset} -> ${blue}git restore${reset} -> Restore working tree files\n"
    printf "${green}grset${reset} -> ${blue}git remote set-url${reset} -> Change the URL of a remote\n"
    printf "${green}grss${reset} -> ${blue}git restore --source${reset} -> Restore from a specific source\n"
    printf "${green}grst${reset} -> ${blue}git restore --staged${reset} -> Restore staged changes\n"
    printf "${green}grt${reset} -> ${blue}cd \"\$(git rev-parse --show-toplevel || echo .)\"${reset} -> Change directory to the top-level of the working tree\n"
    printf "${green}gru${reset} -> ${blue}git reset --${reset} -> Unstage all changes\n"
    printf "${green}grup${reset} -> ${blue}git remote update${reset} -> Update all remotes\n"
    printf "${green}grv${reset} -> ${blue}git remote --verbose${reset} -> Show verbose output for remotes\n"
    printf "${green}gsb${reset} -> ${blue}git status --short --branch${reset} -> Show the working tree status in short format\n"
    printf "${green}gsd${reset} -> ${blue}git svn dcommit${reset} -> Commit to SVN repository\n"
    printf "${green}gsh${reset} -> ${blue}git show${reset} -> Show various types of objects\n"
    printf "${green}gsi${reset} -> ${blue}git submodule init${reset} -> Initialize submodules\n"
    printf "${green}gsps${reset} -> ${blue}git show --pretty=short --show-signature${reset} -> Show commit with signature\n"
    printf "${green}gsr${reset} -> ${blue}git svn rebase${reset} -> Rebase on top of SVN repository\n"
    printf "${green}gss${reset} -> ${blue}git status --short${reset} -> Show the working tree status in short format\n"
    printf "${green}gst${reset} -> ${blue}git status${reset} -> Show the working tree status\n"
    printf "${green}gsta${reset} -> ${blue}git stash push${reset} -> Stash the changes in a dirty working directory\n"
    printf "${green}gstaa${reset} -> ${blue}git stash apply${reset} -> Apply the changes recorded in the stash\n"
    printf "${green}gstall${reset} -> ${blue}git stash --all${reset} -> Stash all changes\n"
    printf "${green}gstc${reset} -> ${blue}git stash clear${reset} -> Clear all stashes\n"
    printf "${green}gstd${reset} -> ${blue}git stash drop${reset} -> Remove a single stash entry\n"
    printf "${green}gstl${reset} -> ${blue}git stash list${reset} -> List all stashes\n"
    printf "${green}gstp${reset} -> ${blue}git stash pop${reset} -> Apply and remove a single stash entry\n"
    printf "${green}gsts${reset} -> ${blue}git stash show --patch${reset} -> Show the changes recorded in the stash\n"
    printf "${green}gsu${reset} -> ${blue}git submodule update${reset} -> Update submodules\n"
    printf "${green}gsw${reset} -> ${blue}git switch${reset} -> Switch branches\n"
    printf "${green}gswc${reset} -> ${blue}git switch --create${reset} -> Create and switch to a new branch\n"
    printf "${green}gswd${reset} -> ${blue}git switch \$(git_develop_branch)${reset} -> Switch to the develop branch\n"
    printf "${green}gswm${reset} -> ${blue}git switch \$(git_main_branch)${reset} -> Switch to the main branch\n"
    printf "${green}gta${reset} -> ${blue}git tag --annotate${reset} -> Create an annotated tag\n"
    printf "${green}gtl${reset} -> ${blue}gtl(){ git tag --sort=-v:refname -n --list \"\${1}*\" }; noglob gtl${reset} -> List tags with details\n"
    printf "${green}gts${reset} -> ${blue}git tag --sign${reset} -> Create a signed tag\n"
    printf "${green}gtv${reset} -> ${blue}git tag | sort -V${reset} -> List tags sorted by version\n"
    printf "${green}gunignore${reset} -> ${blue}git update-index --no-assume-unchanged${reset} -> Stop ignoring changes to a file\n"
    printf "${green}gunwip${reset} -> ${blue}git rev-list --max-count=1 --format=\"%s\" HEAD | grep -q \"--wip--\" && git reset HEAD~1${reset} -> Undo the last WIP commit\n"
    printf "${green}gwch${reset} -> ${blue}git whatchanged -p --abbrev-commit --pretty=medium${reset} -> Show what changed, with patch\n"
    printf "${green}gwip${reset} -> ${blue}git add -A; git rm \$(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message \"--wip-- [skip ci]\"${reset} -> Commit a WIP (Work In Progress)\n"
    printf "${green}gwipe${reset} -> ${blue}git reset --hard && git clean --force -df${reset} -> Hard reset and clean the working directory\n"
    printf "${green}gwt${reset} -> ${blue}git worktree${reset} -> Manage multiple working trees\n"
    printf "${green}gwta${reset} -> ${blue}git worktree add${reset} -> Add a working tree\n"
    printf "${green}gwtls${reset} -> ${blue}git worktree list${reset} -> List all working trees\n"
    printf "${green}gwtmv${reset} -> ${blue}git worktree move${reset} -> Move a working tree\n"
    printf "${green}gwtrm${reset} -> ${blue}git worktree remove${reset} -> Remove a working tree\n"
    printf "${green}glcr${reset} -> ${blue}edit and amend last commit message in VS Code${reset} -> Open the last commit message in VS Code for editing and amend the commit\n"
}

function gah() {
    gah_raw | fzf \
        --ansi \
        --layout=reverse \
        --preview 'echo {} | awk -F "->" "{for (i=1; i<=NF; i++) print \$i}"' \
        --preview-window=up:5
}
