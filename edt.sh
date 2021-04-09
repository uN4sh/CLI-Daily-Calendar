#!/bin/sh
# requires jq, recode
day=${1:-`date +%Y-%m-%d`}; td=$((${2:-1}-1)); tdlst=( 'S6 INFO TD01' 'S6 INFO TD02' 'S6 INFO TD03' 'S6 INFO TD04' )
curl -s --data "start=${day}&end=${day}&resType=103&calView=agendaDay&federationIds[]=${tdlst[$td]}" https://edt.uvsq.fr/Home/GetCalendarData | recode html > /tmp/res.json

echo -e "\n\033[33;01m 📆 EDT du ${day} — TD${2:-1}\033[0m\n"

jq -c 'sort_by(.start)|.[]' "/tmp/res.json" | while read i; do
    deb=`echo "${i}" | jq -c ".start" | sed -e 's/^"//' -e 's/"$//'`; deb=$(date --date=${deb} "+%Hh%M");
    end=`echo "${i}" | jq -c ".end" | sed -e 's/^"//' -e 's/"$//'`; end=$(date --date=${end} "+%Hh%M");
 
    desc=`echo "${i}" | jq -c ".description"`
    desc=${desc//rn/}; desc=${desc//\"/}; desc=${desc//'<br />'/';'}; # Retrait des 'rn', guillemets et 'br'
    IFS=';'; splitted=($desc); unset IFS; # Split entre les ; en un array 

    mod=`echo ${splitted[2]}`; mod=`echo ${mod} | cut -c 3-$((${#mod}-11))`
    
    echo -e "\033[2m$deb — $end\033[0m\n\033[37;1m${mod}\033[0m\n| ${splitted[0]}\n| ${splitted[1]}\n" # HEURE DÉBUT - HEURE FIN\n MODULE\n TYPE - SALLE           
done