module Data.Room exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (string, int, list, Decoder, at)
import Json.Decode.Pipeline exposing (decode, required)
import Http

type alias Room =
    { title : String
    , description : String
    , user_id : Int
    }

roomDecoder : Decoder Room
roomDecoder =
    decode Room
        |> required "title" string
        |> required "description" string
        |> required "user_id" int

viewRoom : Room -> Html Msg
viewRoom room =
    tr []
        [ td [] [ text (room.title ++ " (" ++ toString room.user_id ++ ")") ]
        , td [] [ text room.description ]
        ]