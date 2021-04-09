# CLI-Daily-Calendar (Celcat)

Bash script to query the [UVSQ Celcat Calendar](https://edt.uvsq.fr/) application to retrieve the day's schedule of courses displayed cleanly on the terminal. 

## Usage
```bash
$ chmod +x edt.sh
$ bash edt.sh [DATE] [TD]
```

## Requires
- `jq` flexible command-line JSON processor
- `recode` converts files between character sets

## Customize the default configuration
- Type your college domain here replacing UVSQ 
``` bash
https://edt.uvsq.fr/Home/GetCalendarData
```
  
- Type group codes as mentioned on your [Celcat Calendar](https://edt.uvsq.fr/).

```bash
td_list=( 'S6 INFO TD01' 'S6 INFO TD02' 'S6 INFO TD03' 'S6 INFO TD04' ) # Semester 6 INFO by default
day=${1:-`date +%Y-%m-%d`};  # Today's date by default
td=$((${2:-X}-1));  # TDX by default, replace with [1, 2, 3, 4]
```

## Output preview

```bash
 📆 EDT du 2021-04-08 — TD1 INFO

08h00 — 09h20
IN603 - CRYPTOGRAPHIE
| CM
| MOODLE

14h30 — 17h20
IN608 - Projet Informatique
| TD
| RC14 - BUFFON
```

## Script details

1. Save the JSON result of the query in a temporary file `/tmp/res.json`, HTML recoded for the accented characters
```bash
curl -s --data "start=${day}&end=${day}&resType=103&calView=agendaDay&federationIds[]=${tdlst[$td]}" https://edt.uvsq.fr/Home/GetCalendarData | recode html > /tmp/res.json
```
2. Sort the day's sessions by start time and start a `while loop` in the sessions array
```bash
jq -c 'sort_by(.start)|.[]' "/tmp/res.json" | while read i; do
  # ...
done
```
3. Parse and format the `datetime` objects to `HH:MM`
```bash
deb=`echo "${i}" | jq -c ".start" | sed -e 's/^"//' -e 's/"$//'`; deb=$(date --date=${deb} "+%Hh%M");
    end=`echo "${i}" | jq -c ".end" | sed -e 's/^"//' -e 's/"$//'`; end=$(date --date=${end} "+%Hh%M");
```
4. Parse and format the `description` field to extract the course name, room, type and group
```bash
desc=${desc//rn/}; desc=${desc//\"/}; # Removal of residual characters
IFS='<br />'; splitted=($desc); unset IFS; # Split the string into an array object
```
5. Cut to format the course name without the duplicate course code
```bash
mod=`echo ${splitted[2]}`; mod=`echo ${mod} | cut -c 3-$((${#mod}-11))`
```
6. Format and prints the schedule of the day's sessions 
```bash
echo -e "\n\033[33;01m 📆 EDT du ${day} — TD${2:-1}\033[0m\n"
echo -e "\033[2m$deb — $end\033[0m\n\033[37;1m${mod}\033[0m\n| ${splitted[0]}\n| ${splitted[1]}\n"
```




