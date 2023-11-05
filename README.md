# inha-CSE2113-prj-1
오픈소스SW개론 1번 프로젝트입니다.

# 실행 방법
```
cd PATH-TO-SCRIPT-FILE
./[filename].sh
```

# 구현 내용

```bash
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
```

이름과 학번을 출력하고 메뉴를 출력합니다.

이후 사용자가 요청한 기능을 하는 함수를 호출하며, 9가 입력되면 `Bye!` 를 출력하고 프로그램을 종료합니다.

구현한 함수의 목록은 다음과 같습니다.

1. Get the data of the movie identified by a specific 'movie id' from 'u.item'
2. Get the data of ‘action’ genre movies from 'u.item’
3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’
4. Delete the ‘IMDb URL’ from ‘u.item’
5. Get the data about users from 'u.user’
6. Modify the format of 'release date' in 'u.item’
7. Get the data of movies rated by a specific 'user id' from 'u.data'
8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'

---

## Get the data of the movie identified by a specific 'movie id' from 'u.item'
```
function func1() {
  read -p "${MSG[1]}" movieId

  awk -F '|' -v query="$movieId" '$1 == query' u.item
}
```
1번 메시지에 해당하는 prompt를 띄우고, 사용자가 입력한 movie id를 movieId 변수에 저장합니다.

파일 u.item에 대해 `|`를 delimter로 하는 awk 스크립트를 실행합니다.

스크립트는 1번 필드가 movieId와 같은 라인을 출력합니다.

## Get the data of ‘action’ genre movies from 'u.item’
```
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
```
2번 메시지에 해당하는 prompt를 띄우고, 출력을 할지 사용자에게 허가를 받습니다.

사용자가 `y`를 입력하지 않은 경우 함수를 종료합니다. (이하 prompt와 입력 받는 부분에 대한 설명은 모두 동일하므로 생략합니다.)

파일 u.item에 대해 `|`를 delimter로 하는 awk 스크립트를 실행합니다.

스크립트는 7번 필드가 1인 라인, 즉 액션 장르의 영화에 대한 라인을 출력합니다. 단, 10번째 출력 이후 `cnt < 10` 조건을 만족하지 않아 최대 10개 까지만 출력하게 됩니다.

## Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’
```
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
```

파일 u.data에 대해 awk 스크립트를 실행합니다.

스크립트는 2번 필드(movie id)가 movieId와 일치하는 필드에 대해, 3번 필드(rating)의 합과 평점의 개수를 계산합니다. 마지막으로 평균 평점을 반올림하여 소수점 5째 자리까지 출력합니다.

## Delete the ‘IMDb URL’ from ‘u.item’
```
function func4() {
  read -p "${MSG[4]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  head -n 10 u.item | sed 's/[^|]*|/|/5'
}
```

파일 u.item에 대해 sed 스크립트를 실행합니다.

스크립트는 정규표현식 `[^|]*|`을 5번째로 만족하는 부분(즉 "IMDb URL|")을 `|`로 치환하여 IMDb URL을 삭제한 것과 동일한 결과를 출력합니다.

## Get the data about users from 'u.user’
```
function func5() {
  read -p "${MSG[5]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  head -n 10 u.user | sed 's/|M|/|Male|/; s/|F|/|Female|/' | sed -E 's/([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)/user \1 is \2 years old \3 \4/'
}
```

head와 -n 옵션을 활용해 파일 u.user의 처음 10라인을 다음 sed 스크립트로 전달합니다.

스크립트는 `|M|`을 `|Male|`로, `|F|`를 `|Female|`로 치환한 결과를 다음 sed 스크립트로 전달합니다.

마지막 스크립트는 정규표현식 `[^|]*|`과 매칭되는 5개의 subexpression을 구하고, 요구한 형식에 맞추어 출력합니다.

## Modify the format of 'release date' in 'u.item’
```
function func6() {
  read -p "${MSG[6]}" choice

  if [ "$choice" != "y" ]; then
    return
  fi

  tail -n 10 u.item \
    | sed -E 's/([^|]*\|[^|]*\|[0-9]{2}\-)(Jan)(.*)/\101\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Feb)(.*)/\102\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Mar)(.*)/\103\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Apr)(.*)/\104\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(May)(.*)/\105\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Jun)(.*)/\106\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Jul)(.*)/\107\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Aug)(.*)/\108\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Sep)(.*)/\109\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Oct)(.*)/\110\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Nov)(.*)/\111\3/; s/([^|]*\|[^|]*\|[0-9]{2}\-)(Dec)(.*)/\112\3/' \
    | sed -E 's/([^|]*\|[^|]*\|)([^-]*)\-([^-]*)\-([^|]*)(\|.*)/\1\4\3\2\5/'
}
```

tail과 -n 옵션을 활용해 파일 u.item의 마지막 10라인을 다음 sed 스크립트로 전달합니다.

스크립트는 정규표현식을 활용해 (월 표기의 이전 부분)(월 표기)(월 표기의 이후 부분) 3개의 subexpression을 구하고, Jan은 01로, Feb는 02로, Mar는 03로, ..., Dec는 12로 치환하여 다음 sed 스크립트로 전달합니다.
- 예를 들어 01-Jan-1995 형식의 날짜는 01-01-1995 형식이 됩니다.

마지막 스크립트는 정규표현식을 활용해 (날짜 표기의 이전 부분)(일)-(월)-(연)(날짜 표기의 이후 부분) 5개의 subexpression을 구하고, 불필요한 `-`는 삭제한 뒤 요구사항에 따라 (연)(월)(일) 순서로 바꾸어 출력합니다.

## Get the data of movies rated by a specific 'user id' from 'u.data'
```
function func7() {
  read -p "${MSG[7]}" userId

  movies=$(awk -v userId=$userId '
    $1 == userId {
      print $2
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
```

movies 변수는 파일 u.data에서 1번 필드(user id)가 userId와 일치하는 라인의 2번 필드(movie id)를 출력한 내용을 정렬하여 중복을 제거한 내용과 같습니다.

위 내용은 `bash 3.2` 기준 공백으로 구분되어 있으므로, tr을 활용해 공백을 `|`로 변환하여 출력합니다. 또한 아래의 awk 스크립트에서 활용하기 위해 임시 파일 `.prj1_temp`에 저장합니다.

마지막 awk 스크립트는 `.prj1_temp`와 `u.item`를 입력으로 받습니다. 특히 `u.item`의 delimter는 `|`로 합니다.

각 파일의 시작마다 1로 초기화되는 `FNR`을 활용하여, `.prj1_temp`에 작성된 movie id들을 check의 유효한 key로 사용합니다.

u.item을 읽기 시작하면, 1번 필드(movie id)가 check의 유효한 key인지 확인하여 최대 10개의 `movie id|movie title` 라인을 출력합니다.

마지막으로 더 이상 임시파일은 필요하지 않으므로 삭제합니다.

## Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'
```
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
```

users 변수는 파일 u.user에서 2번 필드(age)가 20 이상 30 미만이며 4번 필드(occupation)가 `programmer`와 일치하는 라인의 user id를 출력한 내용과 같습니다.

위 내용은 `bash 3.2` 기준 공백으로 구분되어 있으므로, tr을 활용해 공백을 `\n`로 변환하여 임시 파일 `.prj1_temp`에 저장합니다.

마지막 awk 스크립트는 `.prj1_temp`와 `u.data`를 입력으로 받습니다.

각 파일의 시작마다 1로 초기화되는 `FNR`을 활용하여, `.prj1_temp`에 작성된 user id들을 check의 유효한 key로 사용합니다.

u.data를 읽기 시작하면, 1번 필드(user id)가 check의 유효한 key인지 확인하여 각 평가에 해당하는 영화의 rating의 합과 개수를 계산합니다. 이 때 2번 필드(movie id)를 key로 사용합니다.

마지막으로 모든 유효한 movie id에 대해, movie id와 6째 자리에서 반올림한 평점을 출력합니다. 단, 출력은 sort로 전달되어 마지막엔 정렬된 채로 출력됩니다.

마지막으로 더 이상 임시파일은 필요하지 않으므로 삭제합니다.
