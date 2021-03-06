#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/includes.sh"

# This is the setup script for to easily create a secrets.env file for a Push Backend Server.

# I have no idea how to pass in variables to a bash function, figure that out.
# This will just stub otherwise
function check_host_resolution {
  echo -e "Check that \e[96m$host\e[0m resolves properly..."
  curl -H $host
  #check that headers are 200, 404, 502 (maybe 500?) everything that's not 'did not resolve'
}

# Generates a secret key long enough and unique enough for devise and rails
function generate_secret_key {
  dd if=/dev/random bs=64 count=1 2>/dev/null | od -An -tx1 | tr -d ' \t\n'
}


echoc "Here we'll be creating all the settings that lets your server talk to your CMS..."
echoc "\n-------------------------------------------------------------------------------------------------------------\n" $LIGHT_BLUE

echoc "First, what type of CMS do you have?\n"
# bash options list?
PS3='Please enter your choice: '
<<<<<<< HEAD
options=("Wordpress" "Newscoop" "Joomla" "Codeigniter" "Blox" "Drupal")
=======
options=("Wordpress" "Newscoop" "Joomla" "Codeigniter" "Blox" "SNWorks/CEO")
>>>>>>> 0930adbdfb041837e23849e58e3e4182238a5b74
select opt in "${options[@]}"
do
    case $opt in
        "Wordpress")
            cms='Wordpress';
            break
            ;;
        "Newscoop")
            cms='Newscoop';
            break
            ;;
        "Joomla")
            cms='Joomla';
            break
            ;;
        "Codeigniter")
            cms='Codeigniter';
            break
            ;;
        "Blox")
            cms='Blox';
            break
            ;;
<<<<<<< HEAD
                  "Drupal")
            cms='Drupal';
=======
        "SNWorks/CEO")
            cms='SNWorks';
>>>>>>> 0930adbdfb041837e23849e58e3e4182238a5b74
            break
            ;;
        *) echo invalid option;;
    esac
done

echoc "Setting up a $cms installation" $GREEN

# Ask the name of the of the site
while true
do
  echo -en "What is the full name of your organization? (e.g. The Sample News)? "
  read title
  if ! [[ -z "${title// }" ]]; then
    break
  else
    echoc "You must type in the name of an Organization." $RED
  fi
done

# Ask the web address of the main cms of the site
while true
do
  echo -en "What is the web address of your $cms CMS (e.g. https://www.mycms.com)? "
  read cms_address
  regex='(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  if ! [[ $cms_address =~ $regex ]]
  then
    echoc "Please try again with a valid URL." $RED
  else
    break
  fi
done

# Ask the name of the site
echoc "\nNext we'll ask for the host name."
echoc "This requires that your host name resolves to this server."
echoc "Please see the README.md if you need more info or you're not sure what that means.\n"

while true
do
  echo -en "What is the host name for this installation (e.g. testapp.pushapp.press)? "
  read host
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! echo "$host" | egrep -qiE "^[A-z0-9-]*[\.]*[A-z0-9]+[\.][A-z]{2,}$" ;then
      echoc "Sorry, I can't seem to parse your url because it's not a valid URL format. Please try again." $RED
    else
      break
    fi
  else
    if ! echo "$host" | grep -qiP "^[A-z0-9-]*[\.]*[A-z0-9]+[\.][A-z]{2,}$" ;then
      echoc "Sorry, I can't seem to parse your url because it's not a valid URL format. Please try again." $RED
    else
      break
    fi
  fi
done

# Ask if they use google search for their cms
echoc "\nDoes your CMS use Google to handle its search functionality [yN]?"
echoc "The answer is probably no, but if your unsure do a search on your site,"
echoc "if there's a Google logo you probably do.\n"

google_search=$(askyn "Do you use Google Search?" $google_search)

# If they use google search ask for the google search id
if [ "$google_search" = true ]; then
  echo "Since you use Google search for your CMS, we need the search engine id."
  if [[ $cms == 'Wordpress' ]]; then
    echo "You can probably find this in the settings in your Wordpress search plugin."
    echo "You can find more information about this in the README.md appendix section."
  fi

  while true
  do
    echo -en "What is the Google Search Engine ID? "
    read google_search_engine_id

    if [[ -z "${google_search_engine_id// }" ]]; then
      echoc "Please type in a Google Search Engine ID."
    else
      break
    fi
  done
fi

# If wordpress
if [[ $cms == 'Wordpress' ]]; then

  # If they use the wp_super_cached_donotcachepage plugin (it's rare)
  echo "Does your Wordpress installation use the WP Super Cache plugin?"
  echo "There will be an entry underneathe your Wordpress's 'Settings' menu."
  echo "You can find more information about this in the README.md appendix section."

  supercache=$(askyn 'Does your Wordpress plugin use the WP Super Cache Plugin?')

  if [ "$supercache" = true ]; then
    # If wordpress && supercache

    # If they use the wp_super_cached_donotcachepage plugin (it's rare)
    echo "Does your Wordpress Super Cache installation use 'donotcache' feature?"
    # Check out Bivol's installation
    echo "It is a feature that must be enabled under the do not cache page."

    donotcacheplugin=$(askyn 'Does your Wordpress Super Cache installation use 'donotcache' feature?')

    if [ "$donotcacheplugin" = true ]; then
      # If wordpress && supercache && wordpress_super_cache_donotcachepage

      # If they use the wp_super_cached_donotcachepage plugin (it's rare)
      echo "What is the hash key for the donotcache feature?"
      # Check out Bivol's installation
      echo "There will be an entry underneathe your Wordpress's 'Settings' menu."
      echo "You can find more information about this in the README.md appendix section."

      while true
      do
        echo -en "What is the the donotcache hash key? "
        read donotcacheplugin_hash

        if [[ -z "${donotcacheplugin_hash// }" ]]; then
          echoc "Please type in a Do Not Cache hash key."
        else
          break
        fi
      done

    fi
  fi
fi

# If Blox
if [[ $cms == 'Blox' ]]; then

  echoc "\nFor Blox we need to know the \"Publication Name\" we're going to work with."
  echoc "You probably have on created already, but steps 1 and 2 here will show"
  echoc "how to find the name. Please use the words under \"Publication\".\n"
  echoc "https://help.bloxcms.com/knowledge-base/applications/editorial/e-editions/tasks/article_4cdcf908-6939-11e5-9de0-ff4540da429f.html\n"

  while true
  do
    echo -en "\"Publication\" name? "
    read blox_publication_name

    if [[ -z "${blox_publication_name// }" ]]; then
      echoc "Please enter a valid \"Publication\" name."
    else
      break
    fi
  done


  echoc "\nFor Blox we need two types of API authentication keys."
  echoc "You need to make an \"eedition\" and an \"editorial\" key/secret set.\n"
  echoc "Instructions to do that are at https://help.bloxcms.com/knowledge-base/applications/settings/webservice_keys/workspace/article_a73d51da-2bd7-11e5-8dfd-e7325582d658.html\n"

  # eedition and editorial both require a "key" and a "secret"

  while true
  do
    echo -en "\"eedition\" key? "
    read blox_eedition_key

    if [[ -z "${blox_eedition_key// }" ]]; then
      echoc "Please enter a valid \"eedition\" key."
    else
      break
    fi
  done

  while true
  do
    echo -en "\"eedition\" secret? "
    read blox_eedition_secret

    if [[ -z "${blox_eedition_secret// }" ]]; then
      echoc "Please enter a valid \"eedition\" secret."
    else
      break
    fi
  done

  while true
  do
    echo -en "\"editorial\" key? "
    read blox_editorial_key

    if [[ -z "${blox_editorial_key// }" ]]; then
      echoc "Please enter a valid \"eedition\" key."
    else
      break
    fi
  done

  while true
  do
    echo -en "\"editorial\" secret? "
    read blox_editorial_secret

    if [[ -z "${blox_editorial_secret// }" ]]; then
      echoc "Please enter a valid \"editorial\" secret."
    else
      break
    fi
  done
fi

# If SNWorks CEO
if [[ $cms == 'SNWorks' ]]; then

  echoc "\nFor SNWorks we need the authentication keys provided by the CMS."
  echoc "To do that follow step 1 here http://static.getsnworks.com/ceo/api/"
  
  while true
  do
    echo -en "Public Key? "
    read snworks_public_api_key
    
    if [[ -z "${snworks_public_api_key// }" ]]; then
      echoc "Please enter a valid Public Key"
    else
      break
    fi
  done
  
  while true
  do
    echo -en "Private Key? "
    read snworks_private_api_key
    
    if [[ -z "${snworks_private_api_key// }" ]]; then
      echoc "Please enter a valid Private Key"
    else
      break
    fi
  done
fi

# Ask for languages
echo "What langauges does your app provide?\n"
echo "We currently support:"
echo "Azerbaijani (az)"
echo "Bulgarian (bg)"
echo "English (en)"
echo "Georigan (ha)" # check this
echo "Romanian (ro)"
echo "Russian (ru)"
echo "Serbian (sr)"

echo "Your app can support as many as you want, but must support at least one."
languages=()
language_options=("Azerbaijani" "Bulgarian" "English" "Georigan" "Romanian" "Russian" "Serbian" "Finished Choosing Languages")

while true
do
  finish=false
  echo "Choose a language to add to your app. "
  PS3='Please enter your choice: '
  select opt in "${language_options[@]}"
  do
      case $opt in
          "Azerbaijani")
              languages+=('az')
              break
              ;;
          "Bulgarian")
              languages+=('bg')
              break
              ;;
          "English")
              languages+=('en')
              break
              ;;
          "Georigan")
              languages+=('ha')
              break
              ;;
          "Romanian")
              languages+=('ro')
              break
              ;;
          "Russian")
              languages+=('ru')
              break
              ;;
          "Serbian")
              languages+=('sr')
              break
              ;;
          "Finished Choosing Languages")
              if ! [[ ${#languages[@]} == 0 ]]; then
                finish=true
              fi
              break
              ;;
          *) echo invalid option;;
      esac
  done

  if [ "$finish" = true ]; then
    if [[ ${#languages[@]} == 0 ]] ; then
      echoc "\nPlease choose at least one language for your app.\n" $RED
    else
      break
    fi
  fi

  index=0
  for language in ${language_options[@]}; do
        echo "$language"
        if [ "$language" = "$opt" ]; then
            unset language_options[$index]
            break
        fi
        let index++
  done


done

# ask for the default language, if there's more than one
if [[ ${#languages[@]} == 1 ]] ; then
  default_language=$languages[0]
else
  echo "Please choose a default language. "
  select opt in "${languages[@]}"
  do
    default_language=$opt
    break
  done
fi


# join the language strings Here
languages=$(join_by , "${languages[@]}")
echo $languages
# check if secrets.env exists and prompt if it does
if basename "$PWD" | grep 'maintence-scripts' > /dev/null; then
  path='../secrets.env'
else
  path='./secrets.env'
fi

if [ ! -f $path ]; then
    echoc "No .env file found, creating it." $YELLOW
else
  replace_env=$(askyn "Found current secrets.env file. Should I replace it?")
  if [ "$replace_env" = true ]; then
    echoc "Removing current .env file" $YELLOW
    rm $path
  else
    exit
  fi
fi

echoc "Creating new .env file" $YELLOW
touch $path

# Write the secrets.env file
echoc "Creating secrets.env file" $GREEN

cms_mode=$(echo "$cms" | tr '[:upper:]' '[:lower:]')
cat <<EOT >> secrets.env
#########################################
#
# Configuration for the Push Backend
# This file was automatically generated
#
#########################################

title="$title"
cms_mode=$cms_mode
$(echo "$cms_mode")_url=$cms_address

force_https=true
google_search_engine_id=$google_search_engine_id
DEVISE_SECRET_KEY=$(generate_secret_key)
SECRET_KEY_BASE=$(generate_secret_key)
wp_super_cached_donotcachepage=$wp_super_cached_donotcachepage
proxy_images=true
host=$host
languages="$languages"
default_language=$default_language

EOT

if [[ $cms == 'Blox' ]]; then
cat <<EOT >> secrets.env
#########################################
#
# TownNews BLOX API access variables
# Instructions to generate these at
# https://help.bloxcms.com/knowledge-base/applications/settings/webservice_keys/workspace/article_a73d51da-2bd7-11e5-8dfd-e7325582d658.html
#
#########################################

blox_publication_name=$blox_publication_name
blox_eedition_key=$blox_eedition_key
blox_eedition_secret=$blox_eedition_secret
blox_editorial_key=$blox_editorial_key
blox_editorial_secret=$blox_editorial_secret

EOT

fi

if [[ $cms == 'SNWorks' ]]; then
cat <<EOT >> secrets.env
#########################################
#
# SNWorks CEO API access variables
# Instructions to generate these at 
# http://static.getsnworks.com/ceo/api/
# 
#########################################

snworks_public_api_key=$snworks_public_api_key
snworks_private_api_key=$snworks_private_api_key

EOT

fi

echo "Finished! If they're already running, please restart your docker containers to update them."
