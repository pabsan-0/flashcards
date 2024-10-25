#! /usr/bin/env bash

# set -x

this_file_path () {
    local SOURCE=${BASH_SOURCE[0]}
    local DIR=

    # resolve $SOURCE until the file is no longer a symlink
    while [ -L "$SOURCE" ]; do 
        DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
        SOURCE=$(readlink "$SOURCE")
        # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
        [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE 
    done
    echo $( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
}

__FLASHCARDS_ROOT=$(this_file_path)

print_usage () {
    echo "Usage: flashcards                        Interactive searh & display "
    echo "                  <card_name>            Display flashcard by name   "
    echo "                  -a, --add <card_name>  Add new flashcard           "
    echo "                  -g, --git              In-context git commands     "
    echo "                  -s, --cd               Open project in subshell    "
}


add_flashcard () {
    cd "$__FLASHCARDS_ROOT" || exit 1

    local dest="$1"

    if [[ -z $dest ]] ; then
        echo No name provided! 
        print_usage
        exit 1
    fi

    if [[ "$dest" == *.fc ]] ; then
        echo Dont add file extension! I will do that for you.
        exit 1
    fi
    dest="$dest.fc"

    if [[ -f "cards/$dest" ]] ; then
        echo File exists! Choose a different name.
        exit 1
    fi

    cp 'assets/template.fc' 'cards/new.fc'
    $EDITOR 'cards/new.fc'

    if cmp -s 'assets/template.fc' 'cards/new.fc' ; then
        # file unmodified, cleanup
        rm 'cards/new.fc'
        exit 1
    else
        # file modified, copy over and preview
        mv 'cards/new.fc' "cards/$dest"
        batcat --color=always "cards/$dest"
        exit 0
    fi

}

case ${1-""} in
    "")
        cd "$__FLASHCARDS_ROOT/cards" || exit 1

        rg  --with-filename .                                   \
            --color=always                                      \
            --field-match-separator ' ' 2> /dev/null           |\
        fzf                                                     \
            --ansi                                              \
            --bind='enter:abort+execute(vim {1})'               \
            --bind=',:abort+execute(vim $(dirname {1}))'        \
            --preview="batcat --color=always --style snip {1} " \
            --header='browse , edit ↵ '                         ;
        ;;

    -n|--names)
        cd "$__FLASHCARDS_ROOT/cards" || exit 1

        find . -type f | fzf                                   \
            --ansi                                              \
            --bind='enter:abort+execute(vim {1})'               \
            --bind=',:abort+execute(vim $(dirname {1}))'        \
            --preview="batcat --color=always --style snip {1} " \
            --header='browse , edit ↵ '                         ;
        ;;

    -a|--add)
        add_flashcard "$2"
        ;;
        
    -g|--git)
        cd "$__FLASHCARDS_ROOT" || exit 1
        shift
        git $@
        ;;

    -s|--cd)
        cd "$__FLASHCARDS_ROOT" || exit 1
        echo "Flashcards: Jumping into subshell on project dir."
        bash -i
        ;;

    -*|--*)
        print_usage
        ;;
esac

