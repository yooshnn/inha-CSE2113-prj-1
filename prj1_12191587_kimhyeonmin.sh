#!/bin/sh


# data
PROFILE="User Name: kimhyeonmin\nStudent Number: 12191587"
USAGE="--------------------------\n[ MENU ]\n1. Get the data of the movie identified by a specific 'movie id' from 'u.item'\n2. Get the data of action genre movies from 'u.item’\n3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’\n4. Delete the ‘IMDb URL’ from ‘u.item\n5. Get the data about users from 'u.user’\n6. Modify the format of 'release date' in 'u.item’\n7. Get the data of movies rated by a specific 'user id' from 'u.data'\n8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'\n9. Exit\n--------------------------"

MSG=("" \
  "Please enter 'movie id'(1~1682):" \
  "Do you want to get the data of ‘action’ genre movies from 'u.item'?(y/n):" \
  "Please enter the 'movie id'(1~1682):" \
  "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" \
  "Do you want to get the data about users from 'u.user'?(y/n):" \
  "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" \
  "Please enter the 'user id'(1~943):" \
  "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" \
)

# functions
function func1() {
  read -p "${MSG[1]}" movieId

  awk -F '|' -v query="$movieId" '$1 == query' u.item
}

function func2() {
  read -p "${MSG[2]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  awk -F '|' '
    BEGIN {
      cnt = 0
    }
    $7 == 1 {
      if (cnt < 10) printf("%s %s\n", $1, $2); cnt++;
    }' u.item
}

function func3() {
  read -p "${MSG[3]}" movieId

  awk -v query=$movieId '
    BEGIN {
      sum = 0
      count = 0
    }
    $2 == query {
      sum += $3
      count++
    }
    END {
      res = NULL
      if (count != 0) res = sum / count
      printf("average rating of %s: %.5f\n", query, res)
    }' u.data
}

function func4() {
  read -p "${MSG[4]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  head -n 10 u.item | sed 's/[^|]*|/|/5'
}

function func5() {
  read -p "${MSG[5]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  head -n 10 u.user | sed 's/|M|/|Male|/; s/|F|/|Female|/' | sed -E 's/([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)/user \1 is \2 years old \3 \4/'
}

function func6() {
  read -p "${MSG[6]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  tail -n 10 u.item \
    | sed -E 's/([^|]*\|[^|]*\|[0-9]{2}\-)(Jan)(.*)/\101\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Feb)(.*)/\102\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Mar)(.*)/\103\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Apr)(.*)/\104\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(May)(.*)/\105\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Jun)(.*)/\106\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Jul)(.*)/\107\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Aug)(.*)/\108\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Sep)(.*)/\109\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Oct)(.*)/\110\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Nov)(.*)/\111\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Dec)(.*)/\112\3/' \
    | sed -E 's/([^|]*\|[^|]*\|)([^-]*)\-([^-]*)\-([^|]*)\|(.*)/\1\4\3\2\5/'
}

function func7() {
  read -p "${MSG[7]}" userId

  movies=$(awk -v userId=$userId '
    BEGIN {
      res = ""
      first = 1
    }
    $1 == userId {
      if (first == 1) {
        res = $2
        first = 0
      } else {
        res = res "\n" $2
      }
    }
    END {
      print res
    }' u.data | sort -n | uniq)

  echo $movies | tr " " "|"

  echo $movies | tr " " "\n" > .prj1_temp

  awk '
    BEGIN {
      cnt = 0
    }
    NR == FNR {
      check[$0] = 1; next
    }
    cnt < 10 && $1 in check {
      cnt++
      printf("%s|%s\n", $1, $2)
    }' .prj1_temp FS='|' u.item

  rm .prj1_temp
}

function func8() {
  read -p "${MSG[8]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  users=$(awk -F '|' '
    20 <= 0+$2 && 0+$2 < 30 && $4 == "programmer" {
      print $1
    }' u.user)

  echo $users | tr " " "\n" > .prj1_temp

  awk '
    NR == FNR {
      check[$0] = 1; next
    }
    $1 in check {
      rate[$2] += $3
      cnt[$2] += 1
    }
    END {
      for (key in rate) {
        printf("%d %.5f\n", key, rate[key] / cnt[key])
      }
    }' .prj1_temp u.data | sort -n

  rm .prj1_temp
}


# welcome message
echo $PROFILE; echo $USAGE


# body of program
while true; do
  read -p "Enter your choice [ 1-9 ] " choice
  if [ "$choice" = "9" ]; then
    echo "Bye!"
    break
  else
    "func$choice"
  fi
done