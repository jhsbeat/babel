module Data.Student exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (string, int, list, Decoder, at)
import Json.Decode.Pipeline exposing (decode, required)
import Http

type alias Student =
    { name : String
    , age : Int
    , subject : String
    , classification : String
    }

studentDecoder : Decoder Student
studentDecoder =
    decode Student
        |> required "name" string
        |> required "age" int
        |> required "subject" string
        |> required "classification" string

viewStudent : Student -> Html Msg
viewStudent student =
    tr []
        [ td [] [ text (student.name ++ " (" ++ toString student.age ++ ")") ]
        , td [] [ text student.subject ]
        , td [] [ text student.classification ]
        ]