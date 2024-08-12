#!/bin/bash

##########
# AUTHOR #
##########
# This script was made by Maediem - maediem@protonmail.com

#############################
# ACKNOWLEDGEMENTS & THANKS #
#############################
#   https://onepace.net/
#   https://github.com/one-pace/one-pace-public-subtitles/tree/main
#   https://docs.google.com/spreadsheets/d/1HQRMJgu_zArp-sLnvFMDzOyjdsht87eFLECxMK858lA/edit#gid=0

################
# REQUIREMENTS #
################
# 1. Bash shell
# 2. Linux-like environment
# 3. Change the variables below to make sure that you provide the right directories
# 4. Make sure you can run the script by running: chmod 700 /path/to/one_pace_to_plex.sh
# 5. Run the script: 
#### If the script is in another directory: /path/to/one_pace_to_plex.sh 
#### If the script is in your current directory: ./one_pace_to_plex.sh 

#########
# NOTES #
#########
# Plex does not have a standard format to support non-contiguous episodes in a single file. With that said, when there will be something like episode 45, 48-49, it will be rename like this: s01e45-e49.
# The episodes might change a bit to ensure a smooth transition.
# Plex will see One Piece as a single season.

#############
# VARIABLES #
#############

# Define color variables
yellow="\e[33m"
blue="\e[34m"
red="\e[31m"
green="\e[32m"
orange="\e[38;5;208m"
reset_color="\e[0m"

# Change the following based on your directories/preferences
#######################################################################################
one_pace_dir="/path/to/One_Pace"
show_title="One Piece 1999 (One Pace)"
dst_dir="/path/to/plex/$show_title"  # Should be the destination you want inside your Plex directory to create links
log_enabled="true"  # if the value is different than "true", it will not write any log
log_file="$HOME/one_pace_to_plex.log"
#######################################################################################

# One Piece Arcs in order
arcs=("Romance Dawn" "Orange Town" "Syrup Village" "Gaimon" "Baratie" "Arlong Park" "The Adventures of Buggy's Crew" "Loguetown" "Reverse Mountain" "Whisky Peak" "The Trials of Koby-Meppo" "Little Garden" "Drum Island" "Arabasta" "Jaya" "Skypiea" "Long Ring Long Land" "Water Seven" "Enies Lobby" "Post-Enies Lobby" "Thriller Bark" "Sabaody Archipelago" "Amazon Lily" "Impel Down" "The Adventures of the Straw Hats" "Marineford" "Post-War" "Return to Sabaody" "Fishman Island" "Punk Hazard" "Dressrosa" "Zou" "Whole Cake Island" "Reverie" "Wano" "Egghead")

arc_regexes=("Romance[\-\_\. ]*Dawn" "Orange[\-\_\. ]Town" "Syrup[\-\_\. ]*Village" "Gaimon" "Baratie" "Arlong[\-\_\. ]*Park" "The[\-\_\. ]*Adventures[\-\_\. ]*of[\-\_\. ]*Buggy[\-\_\.\']*s Crew" "Loguetown" "Reverse[\-\_\. ]*Mountain" "Whiske?y[\-\_\. ]*Peak" "The[\-\_\. ]*Trials[\-\_\. ]*of[\-\_\. ]*Koby[\-\_\. ]*Meppo" "Little[\-\_\. ]*Garden" "Drum[\-\_\. ]*Island" "Arabasta" "Jaya" "Skypiea" "Long[\-\_\. ]*Ring[\-\_\. ]*Long[\-\_\. ]*Land" "Water[\-\_\. ]*Seven" "(^|[^\-]+)Enies[\-\_\. ]*Lobby" "Post[\-\_\. ]*Enies[\-\_\. ]*Lobby" "Thriller[\-\_\. ]*Bark" "Sabaody[\-\_\. ]*Archipelago" "Amazon[\-\_\. ]*Lily" "Impel[\-\_\. ]*Down" "The[\-\_\. ]*Adventures[\-\_\. ]*of[\-\_\. ]*the[\-\_\. ]*Straw[\-\_\. ]*Hats?" "Marineford" "Post[\-\_\. ]*War" "Return[\-\_\. ]*to[\-\_\. ]*Sabaody" "Fishman[\-\_\. ]*Island" "Punk[\-\_\. ]*Hazard" "Dressrosa" "Zou" "Whole[\-\_\. ]*Cake[\-\_\. ]*Island" "Reverie" "Wano" "Egghead")

# Video & subtitle extensions
subtitle_extensions=(".ass" ".srt" ".sub")
allowed_extensions=(".mp4" ".avi" ".mkv" ".flv" ".mov" ".wmv" "${subtitle_extensions[@]}")

# Need to use an array for file names with spaces or special characters
files=()
choice="1"

#############
# FUNCTIONS #
#############

# Write a log entry
log_entry() {
    local src_file=$1
    local dst_file=$2
    local result=$3
    local message=$4
    
    if [ "$log_enabled" = "true" ]; then
        local datetime=$(date '+%Y-%m-%dT%H:%M:%S')
        local log_msg="$datetime src_file=\"$src_file\" dst_file=\"$dst_file\" result=\"$result\" msg=\"$message\""
        echo "$log_msg" >> "$log_file"
    fi
}

# Get the episode based on the arc name and arc number
get_episode() {
    local src_file_arc=$1
    local src_file_arc_nb=$2
    local result="ERROR"
    
    case "$src_file_arc" in
      "Romance Dawn") 
          case "$src_file_arc_nb" in
              "01") result="s01e00" ;;         # Special: Episode of East Blue, Ep. 312 (Intro)
              "02") result="s01e01" ;;         # Romance Dawn: Ep. 1
              "03") result="s01e02" ;;         # Romance Dawn: Ep. 2, 19 --> Cannot use episode 19. It will break the sequence
              "04") result="s01e03" ;;         # Romance Dawn: Ep. 3
              *) ;;
          esac
          ;;
      "Orange Town") 
          case "$src_file_arc_nb" in
              "01") result="s01e04-e05" ;; # Orange Town: Ep. 4-6
              "02") result="s01e06-e07" ;; # Orange Town: Ep. 6-7
              "03") result="s01e08" ;;     # Orange Town: Ep. 8
              *)  ;;
          esac
          ;;
      "Syrup Village") 
          case "$src_file_arc_nb" in
              "01") result="s01e09-e10" ;;     # Syrup Village: Ep. 9-10
              "02") result="s01e11" ;;         # Syrup Village: Ep. 10-11
              "03") result="s01e12" ;;         # Syrup Village: Ep. 12-13
              "04") result="s01e13-e14" ;;     # Syrup Village: Ep. 13-14
              "05") result="s01e15-e16" ;;     # Syrup Village: Ep. 15-17
              "06") result="s01e17" ;;         # Syrup Village: Ep. 17
              *)  ;;
          esac
          ;;
      "Gaimon") 
          case "$src_file_arc_nb" in
              "01") result="s01e18" ;; # Gaimon: Ep. 18
               *)  ;;
          esac
          ;;
      "Baratie") 
          case "$src_file_arc_nb" in
              "01") result="s01e19-e21" ;; # Baratie: Ep. 19-21
              "02") result="s01e22" ;;     # Baratie: Ep. 21-22
              "03") result="s01e23" ;;     # Baratie: Ep. 23-24
              "04") result="s01e24" ;;     # Baratie: Ep. 23-24, 29, 135
              "05") result="s01e25" ;;     # Baratie: Ep. 25
              "06") result="s01e26" ;;     # Baratie: Ep. 26
              "07") result="s01e27-e28" ;; # Baratie: Ep. 27-28
              "08") result="s01e29" ;;     # Baratie: Ep. 28-29
              "09") result="s01e30" ;;     # Baratie: Ep. 30
              *)  ;;
          esac
          ;;
      "Arlong Park") 
          case "$src_file_arc_nb" in
              "01") result="s01e31-e32" ;; # Arlong Park: Ep. 31-32
              "02") result="s01e33" ;;     # Arlong Park: Ep. 32-33 
              "03") result="s01e34" ;;     # Arlong Park: Ep. 33-34
              "04") result="s01e35" ;;     # Arlong Park: Ep. 34-36
              "05") result="s01e36-e37" ;; # Arlong Park: Ep. 36-37
              "06") result="s01e38" ;;     # Arlong Park: Ep. 38-39
              "07") result="s01e39" ;;     # Arlong Park: Ep. 39-40
              "08") result="s01e40-e41" ;; # Arlong Park: Ep. 40-42
              "09") result="s01e42" ;;     # Arlong Park: Ep. 42-43
              "10") result="s01e43-e45" ;; # Arlong Park: Ep. 43-44 --> To 45 to ensure that it follows everything
              *)  ;;
          esac
          ;;
      "The Adventures of Buggy's Crew") 
          case "$src_file_arc_nb" in
            "01") result="s01e46-e47" ;;   # The Adventures of Buggy's Crew :	Ep. 46-47
            *) ;;
          esac
          ;;
      "Loguetown") 
          case "$src_file_arc_nb" in
              "01") result="s01e48-e49" ;;  # Loguetown: Ep. 45, 48-49
              "02") result="s01e50-e51" ;;  # Loguetown: Ep. 48, 50
              "03") result="s01e52-e53" ;;  # Loguetown: Ep. 52-53
              *) ;;
          esac
          ;;
      "Reverse Mountain") 
          case "$src_file_arc_nb" in
              "01") result="s01e54-e62" ;;   # Reverse Mountain: Ep. 54-55, 61-62
              "02") result="s01e63" ;;       # Reverse Mountain: Ep. 62-63
              *) ;;
          esac
          ;;
      "Whisky Peak" | "Whiskey Peak") 
          case "$src_file_arc_nb" in
              "01") result="s01e64-e65" ;; # Whisky Peak: Ep. 64-65
              "02") result="s01e66-e67" ;; # Whisky Peak: Ep. 65-67
              *) ;;
          esac
          ;;
      "The Trials of Koby-Meppo" | "The Trials of KobyMeppo") 
           case "$src_file_arc_nb" in
              "01") result="s01e68-e69" ;; # The Trials of Koby-Meppo: Ep. 68-69
              *) 
          esac
          ;;
      "Little Garden") 
          case "$src_file_arc_nb" in
              "01") result="s01e70-e71" ;; # Little Garden: Ep. 70-71
              "02") result="s01e72" ;;     # Little Garden: Ep. 71-72
              "03") result="s01e73-e74" ;; # Little Garden: Ep. 73-74
              "04") result="s01e75-e76" ;; # Little Garden: Ep. 75-76
              "05") result="s01e77-e78" ;; # Little Garden: Ep. 77-79
              *) ;;
          esac
          ;;
      "Drum Island") 
          case "$src_file_arc_nb" in
              "01") result="s01e79" ;;         # Drum Island: Ep. 78-79
              "02") result="s01e80-e81" ;;     # Drum Island: Ep. 80-81
              "03") result="s01e82-e83" ;;     # Drum Island: Ep. 82-83
              "04") result="s01e84" ;;         # Drum Island: Ep. 84
              "05") result="s01e85-e87" ;;     # Drum Island: Ep. 85-86
              "06") result="s01e88" ;;         # Drum Island: Ep. 83, 86-88
              "07") result="s01e88-e90" ;;     # Drum Island: Ep. 88-90
              "08") result="s01e91" ;;         # Drum Island: Ep. 90-91
              *) ;;
          esac
          ;;
      "Arabasta") 
          case "$src_file_arc_nb" in
              "01") result="s01e92" ;;         # Arabasta: Ep. 92
              "02") result="s01e93-e95" ;;     # Arabasta: Ep. 93-95
              "03") result="s01e96-e99" ;;     # Arabasta: Ep. 96-98
              "04") result="s01e100-e103" ;;   # Arabasta: Ep. 98, 100-101, 103
              "05") result="s01e104" ;;        # Arabasta: Ep. 100, 103-104
              "06") result="s01e105" ;;        # Arabasta: Ep. 105
              "07") result="s01e106" ;;        # Arabasta: Ep. 106
              "08") result="s01e107-e108" ;;   # Arabasta: Ep. 107-108
              "09") result="s01e109-e110" ;;   # Arabasta: Ep. 109-110
              "10") result="s01e111-e112" ;;   # Arabasta: Ep. 111-112
              "11") result="s01e113-e114" ;;   # Arabasta: Ep. 113-114
              "12") result="s01e115" ;;        # Arabasta: Ep. 115-116
              "13") result="s01e116-e118" ;;   # Arabasta: Ep. 113, 116-118
              "14") result="s01e119" ;;        # Arabasta: Ep. 118-119
              "15") result="s01e120-e121" ;;   # Arabasta: Ep. 120-121
              "16") result="s01e122" ;;        # Arabasta: Ep. 121-122
              "17") result="s01e123-e124" ;;   # Arabasta: Ep. 123-124
              "18") result="s01e125-e126" ;;   # Arabasta: Ep. 124-126
              # INCOMPLETE: Waiting on release
              *) ;;
          esac
          ;;
      "Jaya") 
          case "$src_file_arc_nb" in
            "01") result="s01e143-e144" ;; # Jaya: Ep.143-144
            "02") result="s01e145-e146" ;; # Jaya: Ep.145-146
            "03") result="s01e147" ;;      # Jaya: Ep.147
            "04") result="s01e148" ;;      # Jaya: Ep.148
            "05") result="s01e149" ;;      # Jaya: Ep.149
            "06") result="s01e150" ;;      # Jaya: Ep.150
            "07") result="s01e151" ;;      # Jaya: Ep.145,151
            "08") result="s01e152" ;;      # Jaya: Ep.152
            *) ;;
          esac
          ;;
      "Skypiea")
          case "$src_file_arc_nb" in
            "01") result="s01e153" ;;       # Skypiea: Ep.153
            "02") result="s01e154" ;;       # Skypiea: Ep.154
            "03") result="s01e155-e156" ;;  # Skypiea: Ep.155-156
            "04") result="s01e157-e158" ;;  # Skypiea: Ep.157-158
            "05") result="s01e159-e160" ;;  # Skypiea: Ep.159-160
            "06") result="s01e161-e163" ;;  # Skypiea: Ep.161-163
            "07") result="s01e163-e164" ;;  # Skypiea: Ep.163-164
            "08") result="s01e165-e167" ;;  # Skypiea: Ep.165-167
            "09") result="s01e168-e169" ;;  # Skypiea: Ep.168-169
            "10") result="s01e170" ;;       # Skypiea: Ep.170-171
            "11") result="s01e171-e173" ;;  # Skypiea: Ep.171-173
            "12") result="s01e174" ;;       # Skypiea: Ep.172-174
            "13") result="s01e175-e176" ;;  # Skypiea: Ep.175-176
            "14") result="s01e177-e179" ;;  # Skypiea: Ep.177-179
            # INCOMPLETE: Waiting on release
            *) ;;
          esac
          ;;
      "Long Ring Long Land")
          case "$src_file_arc_nb" in
            "01") result="s01e207-e208" ;;     # Long Ring Long Land: Ep.207-209
            "02") result="s01e209-e210" ;;     # Long Ring Long Land: Ep.209-210
            "03") result="s01e211" ;;          # Long Ring Long Land: Ep.211-212
            "04") result="s01e212-e218" ;;     # Long Ring Long Land: Ep.212,215,217-218
            "05") result="s01e219-e226" ;;     # Long Ring Long Land: Ep.219,226
            "06") result="s01e227" ;;          # Long Ring Long Land: Ep.227-228
            *) ;;
          esac
          ;;
      "Water Seven")
          case "$src_file_arc_nb" in
            "01") result="s01e228-e230" ;; # Water Seven: Ep.228-230
            "02") result="s01e231" ;;      # Water Seven: Ep.229-231
            "03") result="s01e232-e234" ;; # Water Seven: Ep.232-234
            "04") result="s01e235" ;;      # Water Seven: Ep.234-235
            "05") result="s01e236" ;;      # Water Seven: Ep.235-236
            "06") result="s01e237-e239" ;; # Water Seven: Ep.237-239
            "07") result="s01e240" ;;      # Water Seven: Ep.239-240
            "08") result="s01e241" ;;      # Water Seven: Ep.240-241
            "09") result="s01e242-e243" ;; # Water Seven: Ep.242-243
            "10") result="s01e244-e245" ;; # Water Seven: Ep.244-246
            "11") result="s01e246-e248" ;; # Water Seven: Ep.246-248
            "12") result="s01e249" ;;      # Water Seven: Ep.248-249
            "13") result="s01e250" ;;      # Water Seven: Ep.249-250
            "14") result="s01e251" ;;      # Water Seven: Ep.250-251, 256, 320
            "15") result="s01e252-e254" ;; # Water Seven: Ep.252-254
            "16") result="s01e255" ;;      # Water Seven: Ep.254-255
            "17") result="s01e256-e257" ;; # Water Seven: Ep.256-257
            "18") result="s01e258" ;;      # Water Seven: Ep.258-259
            "19") result="s01e259-e261" ;; # Water Seven: Ep.259-261
            "20") result="s01e262-e263" ;; # Water Seven: Ep.262-263
            *) ;;
          esac
          ;;
      "Enies Lobby")
          case "$src_file_arc_nb" in
            "01") result="s01e263-e265" ;;     # Enies Lobby: Ep.263-265
            "02") result="s01e266" ;;          # Enies Lobby: Ep.265-266
            "03") result="s01e267" ;;          # Enies Lobby: Ep.266-267
            "04") result="s01e268" ;;          # Enies Lobby: Ep.268-269
            "05") result="s01e269-e270" ;;     # Enies Lobby: Ep.269-271
            "06") result="s01e271-e272" ;;     # Enies Lobby: Ep.271-273
            "07") result="s01e273-e274" ;;     # Enies Lobby: Ep.273-274
            "08") result="s01e275-e276" ;;     # Enies Lobby: Ep.275-276
            "09") result="s01e276-e277" ;;     # Enies Lobby: Ep.276-277
            "10") result="s01e278-e283" ;;     # Enies Lobby: Ep.278
            "11") result="s01e284-e285" ;;     # Enies Lobby: Ep.284-285
            "12") result="s01e286" ;;          # Enies Lobby: Ep.286-287
            "13") result="s01e287-e288" ;;     # Enies Lobby: Ep.287-288
            "14") result="s01e289-e290" ;;     # Enies Lobby: Ep.289-290
            "15") result="s01e290-e293" ;;     # Enies Lobby: Ep.290,293
            "16") result="s01e294-e295" ;;     # Enies Lobby: Ep.294-295
            "17") result="s01e296-e297" ;;     # Enies Lobby: Ep.296-297
            "18") result="s01e298" ;;          # Enies Lobby: Ep.297-298
            "19") result="s01e299-e301" ;;     # Enies Lobby: Ep.299-301
            "20") result="s01e302-e303" ;;     # Enies Lobby: Ep.301-302
            "21") result="s01e304-e305" ;;     # Enies Lobby: Ep.302,304-305
            "22") result="s01e306" ;;          # Enies Lobby: Ep.306-307
            "23") result="s01e307-e309" ;;     # Enies Lobby: Ep.307-309
            "24") result="s01e310-e311" ;;     # Enies Lobby: Ep.310-311
            "25") result="s01e312" ;;          # Enies Lobby: Ep.312
            *) ;;
          esac
          ;;
      "Post-Enies Lobby")
          case "$src_file_arc_nb" in
            "01") result="s01e313-e314" ;;  # Post-Enies Lobby: Ep.313-314
            "02") result="s01e315-e320" ;;  # Post-Enies Lobby: Ep.315-316,319-320,325
            "03") result="s01e321-e322" ;;  # Post-Enies Lobby: Ep.321-322
            "04") result="s01e323-e324" ;;  # Post-Enies Lobby: Ep.323-324
            "05") result="s01e325" ;;       # Post-Enies Lobby: Ep.324-325
            *) ;;
          esac
          ;;
      "Thriller Bark")
          case "$src_file_arc_nb" in
            "01") result="s01e326-e338" ;;  # Thriller Bark: Ep.326,337-339
            "02") result="s01e339" ;;       # Thriller Bark: Ep.339-340
            "03") result="s01e340-e341" ;;  # Thriller Bark: Ep.340-342
            "04") result="s01e342-e344" ;;  # Thriller Bark: Ep.342-344
            "05") result="s01e345-e346" ;;  # Thriller Bark: Ep.345-346
            "06") result="s01e347-e348" ;;  # Thriller Bark: Ep.347-348
            "07") result="s01e349-e350" ;;  # Thriller Bark: Ep.349-350
            "08") result="s01e351-e352" ;;  # Thriller Bark: Ep.351-353
            "09") result="s01e353-e355" ;;  # Thriller Bark: Ep.353-355
            "10") result="s01e356" ;;       # Thriller Bark: Ep.356-357
            "11") result="s01e357-e359" ;;  # Thriller Bark: Ep.357-359
            "12") result="s01e360-e361" ;;  # Thriller Bark: Ep.360-362
            "13") result="s01e362-e363" ;;  # Thriller Bark: Ep.362-363
            "14") result="s01e364-e364" ;;  # Thriller Bark: Ep.364-365
            "15") result="s01e365-e367" ;;  # Thriller Bark: Ep.365-367
            "16") result="s01e368-e369" ;;  # Thriller Bark: Ep.368-369
            "17") result="s01e370-e371" ;;  # Thriller Bark: Ep.370-371
            "18") result="s01e371-e372" ;;  # Thriller Bark: Ep.371-372
            "19") result="s01e373-e374" ;;  # Thriller Bark: Ep.373-374
            "20") result="s01e375-e377" ;;  # Thriller Bark: Ep.375-377
            "21") result="s01e378-e380" ;;  # Thriller Bark: Ep.378-380
            "22") result="s01e381-e384" ;;  # Thriller Bark: Ep.380-381
            *) ;;
          esac
          ;;
      "Sabaody Archipelago")
          case "$src_file_arc_nb" in
            "01") result="s01e385-e386" ;;  # Sabaody Archipelago: Ep.385-386
            "02") result="s01e387-e388" ;;  # Sabaody Archipelago: Ep.387-388
            "03") result="s01e389" ;;       # Sabaody Archipelago: Ep.388-389
            "04") result="s01e390-e391" ;;  # Sabaody Archipelago: Ep.390-391
            "05") result="s01e392-e394" ;;  # Sabaody Archipelago: Ep.392-394
            "06") result="s01e395-e396" ;;  # Sabaody Archipelago: Ep.395-396
            "07") result="s01e397-e398" ;;  # Sabaody Archipelago: Ep.397-398
            "08") result="s01e399" ;;       # Sabaody Archipelago: Ep.399-400
            "09") result="s01e400-e401" ;;  # Sabaody Archipelago: Ep.400-401
            "10") result="s01e402-e404" ;;  # Sabaody Archipelago: Ep.402-404
            "11") result="s01e405-e407" ;;  # Sabaody Archipelago: Ep.404-405
            *) ;;
          esac
          ;;
      "Amazon Lily")
          case "$src_file_arc_nb" in
            "01") result="s01e408-e409" ;; # Amazon Lily: Ep. 408-409
            "02") result="s01e410-e411" ;; # Amazon Lily: Ep. 410-411
            "03") result="s01e412-e413" ;; # Amazon Lily: Ep. 412-413
            "04") result="s01e414-e417" ;; # Amazon Lily: Ep. 414-417
            "05") result="s01e418-e421" ;; # Amazon Lily: Ep. 417-421
            *) ;;
          esac
          ;;
      "Impel Down")
          case "$src_file_arc_nb" in
            "01") result="s01e422-e423" ;; # Impel Down: Ep. 422-423, 454
            "02") result="s01e424-e429" ;; # Impel Down: Ep. 424-425, 430
            "03") result="s01e430-e432" ;; # Impel Down: Ep. 425, 430-432
            "04") result="s01e433-e434" ;; # Impel Down: Ep. 433-434
            "05") result="s01e435-e437" ;; # Impel Down: Ep. 435-438, 446
            "06") result="s01e438-e439" ;; # Impel Down: Ep. 438-440
            "07") result="s01e440-e442" ;; # Impel Down: Ep. 440-443
            "08") result="s01e443-e445" ;; # Impel Down: Ep. 443-446
            "09") result="s01e446-e449" ;; # Impel Down: Ep. 446-450
            "10") result="s01e450-e452" ;; # Impel Down: Ep. 450-451
            *) ;;
          esac
          ;;
      "The Adventures of the Straw Hats")
            case "$src_file_arc_nb" in
              "01") result="s01e453-e458" ;; # The Adventures of the Straw Hats: Ep. 453-456
              *) ;;
            esac
            ;;
      "Marineford")
          case "$src_file_arc_nb" in
            "01") result="s01e459" ;;          # Marineford: Ep. 452, 459
            "02") result="s01e460-e461" ;;     # Marineford: Ep. 459-462
            "03") result="s01e462-e463" ;;     # Marineford: Ep. 462-463
            "04") result="s01e464-e466" ;;     # Marineford: Ep. 464-465
            "05") result="s01e467-e468" ;;     # Marineford: Ep. 467-468
            "06") result="s01e469" ;;          # Marineford: Ep. 468-469
            "07") result="s01e470-e471" ;;     # Marineford: Ep. 470-471
            "08") result="s01e472-e473" ;;     # Marineford: Ep. 472-473
            "09") result="s01e474-e475" ;;     # Marineford: Ep. 474-475
            "10") result="s01e476" ;;          # Marineford: Ep. 476
            "11") result="s01e477-e478" ;;     # Marineford: Ep. 477-478
            "12") result="s01e479-e480" ;;     # Marineford: Ep. 479-480
            "13") result="s01e481-e482" ;;     # Marineford: Ep. 481-482
            "14") result="s01e483-e484" ;;     # Marineford: Ep. 483-484
            "15") result="s01e485" ;;          # Marineford: Ep. 484-485
            "16") result="s01e486-e487" ;;     # Marineford: Ep. 486-487
            "17") result="s01e488-e489" ;;     # Marineford: Ep. 488-489
            *) ;;
          esac
          ;;
      "Post-War" | "Post War")
          case "$src_file_arc_nb" in
            "01") result="s01e490-e492" ;; # Post-War: Ep. 490-491
            "02") result="s01e493-e495" ;; # Post-War: Ep. 493-495
            "03") result="s01e496-e500" ;; # Post-War: Ep. 496-498, 500-501, Episode of Sabo
            "04") result="s01e501-e503" ;; # Post-War: Ep. 501-503
            "05") result="s01e504-e506" ;; # Post-War: Ep. 503-505
            "06") result="s01e507-e519" ;; # Post-War: Ep. 507-510
            "07") result="s01e510-e512" ;; # Post-War: Ep. 510-512
            "08") result="s01e513-e516" ;; # Post-War: Ep. 513-516
            *) ;;
          esac
          ;;
      "Return to Sabaody")
          case "$src_file_arc_nb" in
            "01") result="s01e517-e519" ;;  # Return to Sabaody: Ep. 517-519
            "02") result="s01e520" ;;       # Return to Sabaody: Ep. 518-520
            "03") result="s01e521-e522" ;;  # Return to Sabaody: Ep. 520-522
            *) ;;
          esac
          ;;
      "Fishman Island")
          case "$src_file_arc_nb" in
            "01") result="s01e523-e524" ;; # Fishman Island: Ep. 523-524
            "02") result="s01e525-e526" ;; # Fishman Island: Ep. 524-526
            "03") result="s01e527" ;;      # Fishman Island: Ep. 526-527
            "04") result="s01e528-e529" ;; # Fishman Island: Ep. 528-529
            "05") result="s01e530-e531" ;; # Fishman Island: Ep. 530-531
            "06") result="s01e532-e533" ;; # Fishman Island: Ep. 532-533
            "07") result="s01e534" ;;      # Fishman Island: Ep. 533-534
            "08") result="s01e535-e537" ;; # Fishman Island: Ep. 535-537
            "09") result="s01e538-e539" ;; # Fishman Island: Ep. 538-539, 541
            "10") result="s01e540-e542" ;; # Fishman Island: Ep. 540-541
            "11") result="s01e543-e544" ;; # Fishman Island: Ep. 543-545
            "12") result="s01e545-e546" ;; # Fishman Island: Ep. 545-546
            "13") result="s01e547-e549" ;; # Fishman Island: Ep. 547-550
            "14") result="s01e550-e551" ;; # Fishman Island: Ep. 550-551
            "15") result="s01e552-e553" ;; # Fishman Island: Ep. 552-553
            "16") result="s01e554-e555" ;; # Fishman Island: Ep. 554-556
            "17") result="s01e556-e558" ;; # Fishman Island: Ep. 556-558
            "18") result="s01e559-e560" ;; # Fishman Island: Ep. 559-560
            "19") result="s01e561-e562" ;; # Fishman Island: Ep. 561-562
            "20") result="s01e563-e566" ;; # Fishman Island: Ep. 563-567
            "21") result="s01e567" ;;      # Fishman Island: Ep. 562-567
            "22") result="s01e568-e569" ;; # Fishman Island: Ep. 567-569
            "23") result="s01e570-e571" ;; # Fishman Island: Ep. 570-571
            "24") result="s01e572-e573" ;; # Fishman Island: Ep. 572-573
            *) ;;
          esac
          ;;
      "Punk Hazard")
          case "$src_file_arc_nb" in
            "01") result="s01e574-e579" ;; # Punk Hazard: Ep. 574, 579
            "02") result="s01e580-e583" ;; # Punk Hazard: Ep. 580-583
            "03") result="s01e584" ;;      # Punk Hazard: Ep. 583-585
            "04") result="s01e585-e587" ;; # Punk Hazard: Ep. 585-587
            "05") result="s01e588-e590" ;; # Punk Hazard: Ep. 588-589
            "06") result="s01e591-e592" ;; # Punk Hazard: Ep. 591-592
            "07") result="s01e593-e594" ;; # Punk Hazard: Ep. 593-594
            "08") result="s01e595-e596" ;; # Punk Hazard: Ep. 595-596
            "09") result="s01e597-e598" ;; # Punk Hazard: Ep. 597-598
            "10") result="s01e599-e600" ;; # Punk Hazard: Ep. 599-600
            "11") result="s01e601-e602" ;; # Punk Hazard: Ep. 601-602
            "12") result="s01e603-e604" ;; # Punk Hazard: Ep. 603-604
            "13") result="s01e605-e606" ;; # Punk Hazard: Ep. 604-606
            "14") result="s01e607-e608" ;; # Punk Hazard: Ep. 607-608
            "15") result="s01e609-e610" ;; # Punk Hazard: Ep. 609-610
            "16") result="s01e611-e612" ;; # Punk Hazard: Ep. 611-612
            "17") result="s01e613-e614" ;; # Punk Hazard: Ep. 613-614
            "18") result="s01e615-e616" ;; # Punk Hazard: Ep. 615-616
            "19") result="s01e617-e618" ;; # Punk Hazard: Ep. 617-618
            "20") result="s01e619-e621" ;; # Punk Hazard: Ep. 619-621
            "21") result="s01e622-e623" ;; # Punk Hazard: Ep. 622-623
            "22") result="s01e624-e627" ;; # Punk Hazard: Ep. 624-626, 628
            *) ;;
          esac
          ;;
      "Dressrosa") 
          case "$src_file_arc_nb" in
            "01") result="s01e628-e630" ;;     # Dressrosa: Ep. 628-631
            "03") result="s01e633-e634" ;;     # Dressrosa: Ep. 633-635
            "02") result="s01e631-e632" ;;     # Dressrosa: Ep. 631-633
            "04") result="s01e635-e637" ;;     # Dressrosa: Ep. 634-637
            "05") result="s01e638" ;;          # Dressrosa: Ep. 637-638
            "06") result="s01e639" ;;          # Dressrosa: Ep. 639-642
            "07") result="s01e640-e642" ;;     # Dressrosa: Ep. 640-643
            "08") result="s01e643-e645" ;;     # Dressrosa: Ep. 643-645
            "09") result="s01e646-e647" ;;     # Dressrosa: Ep. 646-647
            "10") result="s01e648-e649" ;;     # Dressrosa: Ep. 648-649
            "11") result="s01e650-e651" ;;     # Dressrosa: Ep. 650-651
            "12") result="s01e652-e654" ;;     # Dressrosa: Ep. 652-654
            "13") result="s01e655-e656" ;;     # Dressrosa: Ep. 655-657
            "14") result="s01e657-e659" ;;     # Dressrosa: Ep. 648, 657-659
            "15") result="s01e660-e661" ;;     # Dressrosa: Ep. 660-661
            "16") result="s01e662-e663" ;;     # Dressrosa: Ep. 657, 662-663
            "17") result="s01e664-e665" ;;     # Dressrosa: Ep. 664-665
            "18") result="s01e666-e667" ;;     # Dressrosa: Ep. 666-667
            "19") result="s01e668-e669" ;;     # Dressrosa: Ep. 668-670
            "20") result="s01e670-e671" ;;     # Dressrosa: Ep. 670-672
            "21") result="s01e672-e674" ;;     # Dressrosa: Ep. 672-675
            "22") result="s01e675-e677" ;;     # Dressrosa: Ep. 675-678
            "23") result="s01e678-e680" ;;     # Dressrosa: Ep. 678-680
            "24") result="s01e681-e683" ;;     # Dressrosa: Ep. 681-683
            "25") result="s01e683-e684" ;;     # Dressrosa: Ep. 683-686
            "26") result="s01e685-e688" ;;     # Dressrosa: Ep. 685-688
            "27") result="s01e688-e691" ;;     # Dressrosa: Ep. 688-691
            "28") result="s01e691-e692" ;;     # Dressrosa: Ep. 691-693
            "29") result="s01e693-e695" ;;     # Dressrosa: Ep. 693-696
            "30") result="s01e696-e698" ;;     # Dressrosa: Ep. 694, 696-698
            "31") result="s01e699-e700" ;;     # Dressrosa: Ep. 699-700
            "32") result="s01e701-e702" ;;     # Dressrosa: Ep. 701-702
            "33") result="s01e703-e704" ;;     # Dressrosa: Ep. 703-704
            "34") result="s01e705-e706" ;;     # Dressrosa: Ep. 705-706
            "35") result="s01e707" ;;          # Dressrosa: Ep. 707-711
            "36") result="s01e708-e710" ;;     # Dressrosa: Ep. 708-711
            "37") result="s01e711-e713" ;;     # Dressrosa: Ep. 711-713
            "38") result="s01e714-e715" ;;     # Dressrosa: Ep. 714-716
            "39") result="s01e716-e719" ;;     # Dressrosa: Ep. 716-719
            "40") result="s01e720-e722" ;;     # Dressrosa: Ep. 714-715, 720-723
            "41") result="s01e723-e725" ;;     # Dressrosa: Ep. 723-725
            "42") result="s01e726-e727" ;;     # Dressrosa: Ep. 726-728
            "43") result="s01e728-e729" ;;     # Dressrosa: Ep. 728-730
            "44") result="s01e730-e733" ;;     # Dressrosa: Ep. 730-733
            "45") result="s01e734-e736" ;;     # Dressrosa: Ep. 734-736
            "46") result="s01e737-e739" ;;     # Dressrosa: Ep. 737-739
            "47") result="s01e740-e741" ;;     # Dressrosa: Ep. 740-742
            "48") result="s01e742-e745" ;;     # Dressrosa: Ep. 742-745
            *) ;;
          esac
          ;;
      "Zou")
          case "$src_file_arc_nb" in
            "01") result="s01e746-e752" ;; # Zou: Ep. 746-747, 751-753
            "02") result="s01e753-e754" ;; # Zou: Ep. 753-754
            "03") result="s01e755-e756" ;; # Zou: Ep. 755-757
            "04") result="s01e757-e758" ;; # Zou: Ep. 757-760
            "05") result="s01e759-e762" ;; # Zou: Ep. 759-762
            "06") result="s01e762-e763" ;; # Zou: Ep. 762-764
            "07") result="s01e764-e766" ;; # Zou: Ep. 764-766
            "08") result="s01e767-e768" ;; # Zou: Ep. 767-769
            "09") result="s01e769-e771" ;; # Zou: Ep. 769-772
            "10") result="s01e772-e776" ;; # Zou: Ep. 772-774, 776
            *) ;;
          esac
          ;;
      "Whole Cake Island")
          case "$src_file_arc_nb" in
            "01") result="s01e777-e782" ;; # Whole Cake Island: Ep. 777-779, 783
            "02") result="s01e783-e784" ;; # Whole Cake Island: Ep. 783-785
            "03") result="s01e785-e787" ;; # Whole Cake Island: Ep. 785-788
            "04") result="s01e788-e790" ;; # Whole Cake Island: Ep. 788-790
            "05") result="s01e791-e792" ;; # Whole Cake Island: Ep. 791-793
            "06") result="s01e793-e795" ;; # Whole Cake Island: Ep. 793-795
            "07") result="s01e796-e797" ;; # Whole Cake Island: Ep. 796-798
            "08") result="s01e798-e799" ;; # Whole Cake Island: Ep. 798-800
            "09") result="s01e800-e803" ;; # Whole Cake Island: Ep. 800-803, 807
            "10") result="s01e804-e805" ;; # Whole Cake Island: Ep. 804-806
            "11") result="s01e806-e808" ;; # Whole Cake Island: Ep. 806-808
            "12") result="s01e809-e811" ;; # Whole Cake Island: Ep. 809-812
            "13") result="s01e812-e815" ;; # Whole Cake Island: Ep. 812-815
            "14") result="s01e814-e816" ;; # Whole Cake Island: Ep. 814-817
            "15") result="s01e817-e819" ;; # Whole Cake Island: Ep. 817-820
            "16") result="s01e820-e822" ;; # Whole Cake Island: Ep. 820-822
            "17") result="s01e823-e825" ;; # Whole Cake Island: Ep. 823-825
            "18") result="s01e826-e827" ;; # Whole Cake Island: Ep. 826-828
            "19") result="s01e828-e830" ;; # Whole Cake Island: Ep. 828-830
            "20") result="s01e831-e832" ;; # Whole Cake Island: Ep. 831-832
            "21") result="s01e833-e834" ;; # Whole Cake Island: Ep. 831, 833-834
            "22") result="s01e835-e836" ;; # Whole Cake Island: Ep. 835-836
            "23") result="s01e837-e838" ;; # Whole Cake Island: Ep. 837-839
            "24") result="s01e839-e840" ;; # Whole Cake Island: Ep. 839-841
            "25") result="s01e841-e842" ;; # Whole Cake Island: Ep. 841-843
            "26") result="s01e843-e845" ;; # Whole Cake Island: Ep. 843-846
            "27") result="s01e846-e847" ;; # Whole Cake Island: Ep. 846-848
            "28") result="s01e848-e850" ;; # Whole Cake Island: Ep. 848-850
            "29") result="s01e851-e852" ;; # Whole Cake Island: Ep. 851-853
            "30") result="s01e853-e855" ;; # Whole Cake Island: Ep. 853-855, 858
            "31") result="s01e856-e857" ;; # Whole Cake Island: Ep. 856-858
            "32") result="s01e858-e859" ;; # Whole Cake Island: Ep. 858-860
            "33") result="s01e860-e861" ;; # Whole Cake Island: Ep. 860-862
            "34") result="s01e862-e864" ;; # Whole Cake Island: Ep. 862-865
            "35") result="s01e865-e866" ;; # Whole Cake Island: Ep. 865-868
            "36") result="s01e867-e870" ;; # Whole Cake Island: Ep. 865, 867-870
            "37") result="s01e871-e872" ;; # Whole Cake Island: Ep. 871-872
            "38") result="s01e873-e875" ;; # Whole Cake Island: Ep. 873-875
            "39") result="s01e876-e877" ;; # Whole Cake Island: Ep. 876-877
            *) ;;
          esac
          ;;
      "Reverie")
          case "$src_file_arc_nb" in
            "01") result="s01e878-e880" ;; # Reverie: Ep. 878-880
            "02") result="s01e881-e885" ;; # Reverie: Ep. 881-885
            "03") result="s01e886-e889" ;; # Reverie: Ep. 886-889
            *) ;;
          esac
          ;;
      "Wano")
          case "$src_file_arc_nb" in
            "01") result="s01e890-e891" ;;   # Wano: Ep. 890-891
            "02") result="s01e892-e893" ;;   # Wano: Ep. 892-894
            "03") result="s01e894-e897" ;;   # Wano: Ep. 894, 897
            "04") result="s01e898-e899" ;;   # Wano: Ep. 898-899
            "05") result="s01e900-e901" ;;   # Wano: Ep. 900-902
            "06") result="s01e902-e903" ;;   # Wano: Ep. 902-903
            "07") result="s01e904-e905" ;;   # Wano: Ep. 904-905
            "08") result="s01e906-e908" ;;   # Wano: Ep. 906, 908-909
            "09") result="s01e909-e910" ;;   # Wano: Ep. 909-911
            "10") result="s01e911-e913" ;;   # Wano: Ep. 911-913
            "11") result="s01e914-e915" ;;   # Wano: Ep. 914-915
            "12") result="s01e916" ;;        # Wano: Ep. 916
            "13") result="s01e917-e918" ;;   # Wano: Ep. 917-919, 924
            "14") result="s01e919-e921" ;;   # Wano: Ep. 919-922
            "15") result="s01e922-e923" ;;   # Wano: Ep. 921-923
            "16") result="s01e924-e925" ;;   # Wano: Ep. 923-926
            "17") result="s01e926-e928" ;;   # Wano: Ep. 926-928
            "18") result="s01e929-e930" ;;   # Wano: Ep. 929-931
            "19") result="s01e931-e933" ;;   # Wano: Ep. 931-934
            "20") result="s01e934-e957" ;;   # Wano: Ep. 934-937
            "21") result="s01e936-e938" ;;   # Wano: Ep. 936-938
            "22") result="s01e939-e940" ;;   # Wano: Ep. 939-940
            "23") result="s01e941-e942" ;;   # Wano: Ep. 941-943
            "24") result="s01e943-e944" ;;   # Wano: Ep. 942-944
            "25") result="s01e945-e946" ;;   # Wano: Ep. 945-947
            "26") result="s01e947-e949" ;;   # Wano: Ep. 947-949
            "27") result="s01e950-e951" ;;   # Wano: Ep. 950-951
            "28") result="s01e952-e953" ;;   # Wano: Ep. 952-953
            "29") result="s01e954" ;;        # Wano: Ep. 954-955
            "30") result="s01e955-e956" ;;   # Wano: Ep. 955-956
            "31") result="s01e957" ;;        # Wano: Ep. 957
            "32") result="s01e958" ;;        # Wano: Ep. 958
            "33") result="s01e959" ;;        # Wano: Ep. 959-960
            "34") result="s01e960" ;;        # Wano: Ep. 960-961
            "35") result="s01e961-e962" ;;   # Wano: Ep. 961-963
            "36") result="s01e963-e964" ;;   # Wano: Ep. 963-964
            "37") result="s01e965-e966" ;;   # Wano: Ep. 964-967
            "38") result="s01e967-e968" ;;   # Wano: Ep. 967-968
            "39") result="s01e969-e970" ;;   # Wano: Ep. 969-971
            "40") result="s01e971-e975" ;;   # Wano: Ep. 971-975
            "41") result="s01e976-e1085" ;;  # Wano: Ep. 976-1085
            *) ;;
          esac
          ;;
      "Egghead")
          case "$src_file_arc_nb" in
            "01") result="s01e1086" ;;         # Egghead: Ep. 1086-1088
            "02") result="s01e1087-e1088" ;;   # Egghead: Ep. 1087-1088
            "03") result="s01e1089-e1090" ;;   # Egghead: Ep. 1089-1090
            "04") result="s01e1091-e1092" ;;   # Egghead: Ep. 1091-1093
            "05") result="s01e1093-e1095" ;;   # Egghead: Ep. 1093-1095
            "06") result="s01e1096-e1097" ;;   # Egghead: Ep. 1096-1097
            "07") result="s01e1098-e1099" ;;   # Egghead: Ep. 1097-1099
            "08") result="s01e1100-e1102" ;;   # Egghead: Ep. 1099-1102
            # INCOMPLETE: Waiting on release
            *) ;;
          esac
          ;;
      *) 
          ;;
    esac
    
    echo "$result"
}

# Validate directories
validate_directories() {
    if [ ! -d "$one_pace_dir" ]; then
        echo -e "${red}Source directory not found: $one_pace_dir${reset_color}"
        exit 1
    fi
    
    if [ ! -d "$dst_dir" ]; then
        echo -e "${yellow}Creating destination directory: $dst_dir${reset_color}"
        mkdir -p "$dst_dir"
    fi
}

# Choose operation
choose_option() {
    while true; do
        echo "Please choose an option:"
        echo -e "${yellow}1${reset_color}. Re-do all the hardlinks"
        echo -e "${yellow}2${reset_color}. Start based on the latest One Piece Arc found"
        echo -e "${yellow}3${reset_color}. Add missing hardlinks"
        echo -e "${yellow}4${reset_color}. Quit"
        
        read -p "Enter your choice: " choice
        
        case $choice in
            1) echo "Re-doing all the hardlinks..."; rm -rf "$dst_dir"; mkdir -p "$dst_dir"; break;;
            2) echo "Starting based on the latest One Piece Arc found..."; update_arcs; break;;
            3) echo "Adding missing hardlinks (checking all Arcs)"; choice="3"; break;;
            4) echo "Quitting..."; exit 0;;
            *) echo -e "${red}Invalid option. Try again.${reset_color}";;
        esac
    done
}

# Update arcs based on the latest found in the destination
update_arcs() {
    local tmp_arcs=()
    local tmp_arc_regexes=()
    local result=""
    
    for ((i=${#arcs[@]}-1; i>=0; i--)); do
        arc="${arcs[i]}"
        arc_regex="${arc_regexes[i]}"
        
        tmp_arcs+=("$arc")
        tmp_arc_regexes+=("$arc_regex")
        
        if [ $(find "$dst_dir" -iname "*$arc*" -type f | wc -l) -eq 0 ]; then
            if [ -z "$result" ]; then
                result="$arc"
            else
                result="$result|$arc"
            fi
        else
            if [ -z "$result" ]; then
                result="$arc"
            else
                result="$result|$arc"
            fi
            break
        fi
    done
    
    arcs=("${tmp_arcs[@]}")
    arc_regexes=("${tmp_arc_regexes[@]}")
    echo "$result"
}

process_files() {
    for file in "${files[@]}"; do
        file_name=$(basename "$file")
        file_dir=$(dirname "$file")
        file_extension="${file_name##*.}"
        file_resolution=$(echo "$file_name" | grep -Po "(480|720|1080|2160)p")
        file_arc=""
        file_arc_nb=""

        if [[ "${allowed_extensions[*]}" =~ "$file_extension" ]]; then
            # Determine the arc and arc number
            for ((i=${#arcs[@]}-1; i>=0; i--)); do
                if echo "$file" | grep -qPi "${arc_regexes[i]}"; then
                    file_arc="${arcs[i]}"
                
                    # Handling exceptions
                    if echo "$file_arc" | grep -qPi "The Adventures of Buggy\'s Crew|The Adventures of the Straw Hats|The Trials of Koby-Meppo"; then
                        file_arc_nb="01"
                    else
                        # Getting the file arc number based on the file name
                        file_arc_nb=$(echo "$file_name" | grep -Poi "${arc_regexes[i]} \d+" | grep -Po "\d+$")
                    fi
                    
                    break
                fi
            done
            
            # Determine the arc number if not found in the file name
            if [ -z "$file_arc_nb" ]; then
                count=1
                sub_ext=""
                for current_ext in "${subtitle_extensions[@]}"; do
                    sub_ext+="\\$current_ext|"
                done
                sub_ext="${sub_ext%|}"
                
                while IFS= read -r -d '' tmp_file; do
                    tmp_file_name=$(basename "$tmp_file")
                    name_without_extension="${tmp_file_name%.*}"
                    if [[ "$file_name" =~ "$name_without_extension" ]]; then
                        break
                    fi
                    ((count++))
                done < <(find "$file_dir" -type f -print0 | sort -z | grep -Pv "($sub_ext)$" --binary-files=text)
                
                # Ensure that we keep the same format/standard for the arc number
                if echo "$count" | grep -qP "^\d$"; then
                    file_arc_nb="0$count"
                else
                    file_arc_nb="$count"
                fi
            fi
            
            # Create the hardlink
            if [ -n "$file_arc" ]; then
                episode=$(get_episode "$file_arc" "$file_arc_nb")
                
                if [[ "$episode" != "ERROR" ]]; then
                    if [ -n "$file_resolution" ]; then
                        link_file_name="${show_title} - ${episode} [$file_arc] [$file_resolution].${file_extension}"
                    else
                        link_file_name="${show_title} - ${episode} [$file_arc].${file_extension}"
                    fi
                    
                    link_target="$dst_dir/$link_file_name"
                    
                    if [ "$choice" == "3" ]; then
                        if [ ! -e "$link_target" ]; then
                            ln "$file" "$link_target"
                            log_entry "$file" "$link_target" "success" "Missing hardlink created successfully."
                            echo -e "Missing hardlink created ${green}successfully${reset_color}: ${yellow}$link_target${reset_color}."
                        else
                            log_entry "$file" "$link_target" "skip" "Hardlink already exists."
                            echo -e "Hardlink already exists for: ${yellow}$link_target${reset_color}. Skipping."
                        fi
                    else
                        ln -f "$file" "$link_target" # Force creating hardlinks
                        log_entry "$file" "$link_target" "success" "Hardlink created successfully."
                        echo -e "Hardlink created ${green}successfully${reset_color}: ${yellow}$link_target${reset_color}."
                    fi
                else
                    log_entry "$file" "N/A" "fail" "Failed to retrieve the episode number."
                    echo -e "Failed to retrieve the episode number: ${yellow}$file${reset_color}"
                fi
            else
                log_entry "$file" "N/A" "fail" "Failed to retrieve the arc name."
                echo -e "Failed to retrieve the arc name: ${yellow}$file${reset_color}"
            fi
        else
            log_entry "$file" "N/A" "fail" "The extension ($file_extension) is not allowed."
            echo -e "File extension ${red}not allowed${reset_color}. The error occurred on the following file: ${yellow}$file${reset_color}."
        fi
    done
}

###############
# MAIN SCRIPT #
###############

validate_directories

# Reset the logs
> "$log_file"  # Reset log file

# Handle multiple files
if [ $(find "$dst_dir" -type f | wc -l) -gt 1 ]; then
    choose_option
fi

# Gather files
if [ "$choice" == "1" ] || [ "$choice" == "3" ]; then
    mapfile -d '' -t files < <(find "$one_pace_dir" -type f -print0)
else
    arc_regex_pattern=$(update_arcs)
    mapfile -d '' -t files < <(find "$one_pace_dir" -type f -print0 | grep -Pzi "$arc_regex_pattern")
fi

# Debugging: Print collected files
#echo -e "${blue}Collected files:${reset_color}"
#for file in "${files[@]}"; do
#    echo "$file"
#done

# Process files
process_files

echo -e "\nThe script ran ${green}successfully${reset_color}.\n"
