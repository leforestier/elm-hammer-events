module Main exposing (main)

import Browser
import HammerEvents exposing (onSwipe)
import Html exposing (..)
import Html.Attributes exposing (..)
import Round exposing (roundNum)


main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type Msg
    = SwipeWithSpeed Float


type alias Model =
    { lastSpeed : Maybe Float
    , speedRecord : Maybe Float
    , achievedNewRecord : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { lastSpeed = Nothing
      , speedRecord = Nothing
      , achievedNewRecord = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SwipeWithSpeed speed ->
            let
                speedRecord =
                    Maybe.withDefault 0 model.speedRecord
            in
            ( { model
                | lastSpeed = Just speed
                , speedRecord = Just <| Basics.max speed speedRecord
                , achievedNewRecord = speed > speedRecord
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Swipe example"
    , body =
        [ div
            [ onSwipe (.velocity >> abs >> roundNum 3 >> SwipeWithSpeed)
            , style "height" "100vh"
            , style "width" "100vw"
            ]
            [ h1 [] [ text "Swipe speed contest" ]
            , newRecordDiv model.achievedNewRecord
            , currentRecordDiv model.speedRecord
            , lastSpeedDiv model.lastSpeed
            ]
        ]
    }


newRecordDiv : Bool -> Html msg
newRecordDiv achievedNewRecord =
    div
        [ class "new-record" ]
        (if achievedNewRecord then
            [ text "New record!!!" ]

         else
            []
        )


currentRecordDiv : Maybe Float -> Html msg
currentRecordDiv speedRecord =
    div
        [ class "current-record" ]
        (case speedRecord of
            Nothing ->
                []

            Just speed ->
                [ text "Current record: "
                , text (String.fromFloat speed)
                ]
        )


lastSpeedDiv : Maybe Float -> Html msg
lastSpeedDiv speed =
    div
        [ class "last-speed" ]
        (case speed of
            Nothing ->
                []

            Just s ->
                [ text (String.fromFloat s) ]
        )
