module Main exposing (main)

import Browser
import HammerEvents exposing (HammerEvent, onRotateCancel, onRotateEnd, onRotateMove, onRotateStart)
import Html exposing (..)
import Html.Attributes exposing (..)


main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


{-| The three attributes of the model are angles in degrees.

    - base: the angle of the wheel at rest
    - rotationStart: the angle that your two fingers make with the horizontal axis when the rotation starts
    (yes, that's a bit strange, but that is how Hammer.js records rotation events. When the rotation starts,
    the value of the `rotation` attribute of the Hammer.js event is not zero. It is set to be that angle that
    the line passing through your two fingers make with the horizontal). We record that value to substract it
    from ulterior rotation angles (they are also expressed by Hammer.js as angles with the horizontal axis)
    - rotationDifference: while you're doing the rotation gesture, `rotationDifference` stores how much you've
    rotated so far.

-}
type alias Model =
    { base : Float, rotationStart : Float, rotationDifference : Float }


{-| the angle of the wheel
-}
wheelAngle : Model -> Float
wheelAngle model =
    model.base + model.rotationDifference


type Msg
    = SetRotationStart Float -- set the initial angle of the rotation gesture -}
    | Rotate Float -- update the rotation angle of the current rotation gesture -}
    | LetGo -- remove your finger from the wheel, ending the rotation gesture -}


{-| css attribute to rotate an element by a certain angle
-}
cssRotate : Float -> Attribute msg
cssRotate angle =
    style "transform" ("rotate(" ++ String.fromFloat angle ++ "deg)")


init : () -> ( Model, Cmd Msg )
init _ =
    ( { base = 0
      , rotationStart = 0
      , rotationDifference = 0
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRotationStart angle ->
            ( { model | rotationStart = angle }
            , Cmd.none
            )

        Rotate angle ->
            ( { model | rotationDifference = angle - model.rotationStart }
            , Cmd.none
            )

        LetGo ->
            ( { model
                | base = model.base + model.rotationDifference
                , rotationStart = 0
                , rotationDifference = 0
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Example of rotation gesture handling"
    , body =
        [ div
            []
            [ img
                [ style "margin-top" "100px"
                , cssRotate (wheelAngle model)
                , src "wheel-md.png"
                , onRotateStart (.rotation >> SetRotationStart)
                , onRotateMove (.rotation >> Rotate)
                , onRotateEnd (\_ -> LetGo)
                , onRotateCancel (\_ -> LetGo)
                ]
                []
            ]
        ]
    }
