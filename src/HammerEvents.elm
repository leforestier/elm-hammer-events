module HammerEvents exposing
    ( HammerEvent
    , onTap
    , onPress
    , onPressUp
    , onSwipe
    , onSwipeLeft
    , onSwipeRight
    , onSwipeUp
    , onSwipeDown
    , onRotate
    , onRotateStart
    , onRotateMove
    , onRotateEnd
    , onRotateCancel
    , onPinch
    , onPinchStart
    , onPinchEnd
    , onPinchMove
    , onPinchIn
    , onPinchOut
    , onPinchCancel
    , onPan
    , onPanStart
    , onPanEnd
    , onPanLeft
    , onPanRight
    , onPanUp
    , onPanDown
    , onPanMove
    , onPanCancel
    , onHammer
    , MessageWithAttrs
    , Direction
    , directionNone
    , directionLeft
    , directionRight
    , directionUp
    , directionDown
    , directionHorizontal
    , directionVertical
    , directionAll
    , Input
    , inputStart
    , inputMove
    , inputEnd
    , inputCancel
    , Point
    , hammerEventDecoder
    , hammerEventToValue
    )

{-|

@docs HammerEvent


## Tap

@docs onTap


## Press

@docs onPress

@docs onPressUp


## Swipe

By default, only horizontal swipe gestures are detected
(`onSwipeLeft` and `onSwipeRight` will work, but `onSwipeDown` or `onSwipeUp` won't).

To detect in all directions, add this to your initialization script in Javascript:

    hammertime.get('swipe').set({direction: Hammer.DIRECTION_ALL })

To detect only vertical swipes, use:

    hammertime.get('swipe').set({direction: Hammer.DIRECTION_VERTICAL })

@docs onSwipe

@docs onSwipeLeft

@docs onSwipeRight

@docs onSwipeUp

@docs onSwipeDown


## Rotation

To be able to use `onRotate`, `onRotateStart`, `onRotateEnd` and `onRotateCancel`,
you need to add this line to your Javascript initialization script:

    hammertime.get('rotate').set({ enable: true });

@docs onRotate

@docs onRotateStart

@docs onRotateMove

@docs onRotateEnd

@docs onRotateCancel


## Pinch

To be able to use `onPinch`, `onPinchStart`, `onPinchEnd`, `onPinchMove` etc...
you need to add this line to your Javascript initialization script:

    hammertime.get('pinch').set({ enable: true });

@docs onPinch

@docs onPinchStart

@docs onPinchEnd

@docs onPinchMove

@docs onPinchIn

@docs onPinchOut

@docs onPinchCancel


## Pan

By default, only horizontal pan gestures are detected
(`onPanLeft` and `onPanRight` will work, but `onPanDown` or `onPanUp` won't).

To detect in all directions, add this to your initialization script in Javascript:

    hammertime.get('pan').set({direction: Hammer.DIRECTION_ALL })

To detect only in the vertical direction, use:

    hammertime.get('pan').set({direction: Hammer.DIRECTION_VERTICAL })

@docs onPan

@docs onPanStart

@docs onPanEnd

@docs onPanLeft

@docs onPanRight

@docs onPanUp

@docs onPanDown

@docs onPanMove

@docs onPanCancel


## Custom event handler

@docs onHammer

@docs MessageWithAttrs

@docs Direction

@docs directionNone
@docs directionLeft
@docs directionRight
@docs directionUp
@docs directionDown
@docs directionHorizontal
@docs directionVertical
@docs directionAll

@docs Input

@docs inputStart
@docs inputMove
@docs inputEnd
@docs inputCancel

@docs Point

@docs hammerEventDecoder

@docs hammerEventToValue

-}

import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode


{-| Record representing an event as emitted by the Hammer.js library.

See <https://hammerjs.github.io/api/#event-object> for explanation about the fields.

-}
type alias HammerEvent =
    { deltaX : Float
    , deltaY : Float
    , deltaTime : Float
    , distance : Float
    , angle : Float
    , velocityX : Float
    , velocityY : Float
    , velocity : Float
    , direction : Direction
    , scale : Float
    , rotation : Float
    , center : Point
    , pointerType : String
    , eventType : Input
    , isFirst : Bool
    , isFinal : Bool
    }


{-| -}
type alias Point =
    { x : Float
    , y : Float
    }


{-| An integer representing the direction of the movement.
It's a combination of flags (see <https://hammerjs.github.io/api/#directions>)
-}
type alias Direction =
    Int


{-| -}
directionNone : Direction
directionNone =
    1


{-| -}
directionLeft : Direction
directionLeft =
    2


{-| -}
directionRight : Direction
directionRight =
    4


{-| -}
directionUp : Direction
directionUp =
    8


{-| -}
directionDown : Direction
directionDown =
    16


{-| -}
directionHorizontal : Direction
directionHorizontal =
    6


{-| -}
directionVertical : Direction
directionVertical =
    24


{-| -}
directionAll : Direction
directionAll =
    30


{-| see <https://hammerjs.github.io/api/#input-events>
-}
type alias Input =
    Int


{-| -}
inputStart : Input
inputStart =
    1


{-| -}
inputMove : Input
inputMove =
    2


{-| -}
inputEnd : Input
inputEnd =
    4


{-| -}
inputCancel : Input
inputCancel =
    8


{-| You shouldn't need this. The events you receive from `onTap`, `onSwipe` etc...
are already decoded into an `HammerEvent` Elm record.

I let this function public just in case you want to use it to make very custom things.

-}
hammerEventDecoder : Decode.Decoder HammerEvent
hammerEventDecoder =
    let
        decoder =
            Decode.succeed HammerEvent
                |> required "deltaX" Decode.float
                |> required "deltaY" Decode.float
                |> required "deltaTime" Decode.float
                |> required "distance" Decode.float
                |> required "angle" Decode.float
                |> required "velocityX" Decode.float
                |> required "velocityY" Decode.float
                |> required "velocity" Decode.float
                |> required "direction" Decode.int
                |> required "scale" Decode.float
                |> required "rotation" Decode.float
                |> required
                    "center"
                    (Decode.map2 Point
                        (Decode.field "x" Decode.float)
                        (Decode.field "y" Decode.float)
                    )
                |> required "pointerType" Decode.string
                |> required "eventType" Decode.int
                |> required "isFirst" Decode.bool
                |> required "isFinal" Decode.bool
    in
    Decode.field "gesture" decoder


{-| This function encodes a HammerEvent Elm record back to a Javascript object.

You probably won't need this unless you want to display an event as a Json string in your views.

-}
hammerEventToValue : HammerEvent -> Encode.Value
hammerEventToValue ev =
    Encode.object
        [ ( "deltaX", Encode.float ev.deltaX )
        , ( "deltaY", Encode.float ev.deltaY )
        , ( "deltaTime", Encode.float ev.deltaTime )
        , ( "distance", Encode.float ev.distance )
        , ( "angle", Encode.float ev.angle )
        , ( "velocityX", Encode.float ev.velocityX )
        , ( "velocityY", Encode.float ev.velocityY )
        , ( "velocity", Encode.float ev.velocity )
        , ( "direction", Encode.int ev.direction )
        , ( "scale", Encode.float ev.scale )
        , ( "rotation", Encode.float ev.rotation )
        , ( "center"
          , Encode.object
                [ ( "x", Encode.float ev.center.x )
                , ( "y", Encode.float ev.center.y )
                ]
          )
        , ( "pointerType", Encode.string ev.pointerType )
        , ( "eventType", Encode.int ev.eventType )
        , ( "isFirst", Encode.bool ev.isFirst )
        , ( "isFinal", Encode.bool ev.isFinal )
        ]


withAttrs : Bool -> Bool -> msg -> MessageWithAttrs msg
withAttrs stopPropagation preventDefault message =
    { message = message
    , stopPropagation = stopPropagation
    , preventDefault = preventDefault
    }


{-| All the functions `onTap`, `onSwipe`, `onRotate` etc... have been defined using
the `onHammer` function.

You probably don't need to use it directly unless you've defined a custom type event using
Hammer.js in Javascript.

-}
onHammer :
    String
    -> (HammerEvent -> MessageWithAttrs msg)
    -> Attribute msg
onHammer eventName transformEvent =
    Events.custom eventName (hammerEventDecoder |> Decode.map transformEvent)


{-| -}
type alias MessageWithAttrs msg =
    { message : msg, stopPropagation : Bool, preventDefault : Bool }


onHammerAttrsTrue : String -> (HammerEvent -> msg) -> Attribute msg
onHammerAttrsTrue eventName toMsg =
    onHammer eventName (withAttrs True True << toMsg)


{-| -}
onTap : (HammerEvent -> msg) -> Attribute msg
onTap =
    onHammerAttrsTrue "tap"


{-| -}
onPress : (HammerEvent -> msg) -> Attribute msg
onPress =
    onHammerAttrsTrue "press"


{-| -}
onPressUp : (HammerEvent -> msg) -> Attribute msg
onPressUp =
    onHammerAttrsTrue "pressup"


{-| -}
onSwipe : (HammerEvent -> msg) -> Attribute msg
onSwipe =
    onHammerAttrsTrue "swipe"


{-| -}
onSwipeRight : (HammerEvent -> msg) -> Attribute msg
onSwipeRight =
    onHammerAttrsTrue "swiperight"


{-| -}
onSwipeLeft : (HammerEvent -> msg) -> Attribute msg
onSwipeLeft =
    onHammerAttrsTrue "swipeleft"


{-| -}
onSwipeUp : (HammerEvent -> msg) -> Attribute msg
onSwipeUp =
    onHammerAttrsTrue "swipeup"


{-| -}
onSwipeDown : (HammerEvent -> msg) -> Attribute msg
onSwipeDown =
    onHammerAttrsTrue "swipedown"


{-| -}
onRotate : (HammerEvent -> msg) -> Attribute msg
onRotate =
    onHammerAttrsTrue "rotate"


{-| -}
onRotateStart : (HammerEvent -> msg) -> Attribute msg
onRotateStart =
    onHammerAttrsTrue "rotatestart"


{-| -}
onRotateMove : (HammerEvent -> msg) -> Attribute msg
onRotateMove =
    onHammerAttrsTrue "rotatemove"


{-| -}
onRotateEnd : (HammerEvent -> msg) -> Attribute msg
onRotateEnd =
    onHammerAttrsTrue "rotateend"


{-| -}
onRotateCancel : (HammerEvent -> msg) -> Attribute msg
onRotateCancel =
    onHammerAttrsTrue "rotatecancel"


{-| -}
onPinch : (HammerEvent -> msg) -> Attribute msg
onPinch =
    onHammerAttrsTrue "pinch"


{-| -}
onPinchStart : (HammerEvent -> msg) -> Attribute msg
onPinchStart =
    onHammerAttrsTrue "pinchstart"


{-| -}
onPinchMove : (HammerEvent -> msg) -> Attribute msg
onPinchMove =
    onHammerAttrsTrue "pinchmove"


{-| -}
onPinchEnd : (HammerEvent -> msg) -> Attribute msg
onPinchEnd =
    onHammerAttrsTrue "pinchend"


{-| -}
onPinchCancel : (HammerEvent -> msg) -> Attribute msg
onPinchCancel =
    onHammerAttrsTrue "pinchcancel"


{-| -}
onPinchIn : (HammerEvent -> msg) -> Attribute msg
onPinchIn =
    onHammerAttrsTrue "pinchin"


{-| -}
onPinchOut : (HammerEvent -> msg) -> Attribute msg
onPinchOut =
    onHammerAttrsTrue "pinchout"


{-| -}
onPan : (HammerEvent -> msg) -> Attribute msg
onPan =
    onHammerAttrsTrue "pan"


{-| -}
onPanStart : (HammerEvent -> msg) -> Attribute msg
onPanStart =
    onHammerAttrsTrue "panstart"


{-| -}
onPanMove : (HammerEvent -> msg) -> Attribute msg
onPanMove =
    onHammerAttrsTrue "panmove"


{-| -}
onPanEnd : (HammerEvent -> msg) -> Attribute msg
onPanEnd =
    onHammerAttrsTrue "panend"


{-| -}
onPanCancel : (HammerEvent -> msg) -> Attribute msg
onPanCancel =
    onHammerAttrsTrue "pancancel"


{-| -}
onPanLeft : (HammerEvent -> msg) -> Attribute msg
onPanLeft =
    onHammerAttrsTrue "panleft"


{-| -}
onPanRight : (HammerEvent -> msg) -> Attribute msg
onPanRight =
    onHammerAttrsTrue "panright"


{-| -}
onPanUp : (HammerEvent -> msg) -> Attribute msg
onPanUp =
    onHammerAttrsTrue "panup"


{-| -}
onPanDown : (HammerEvent -> msg) -> Attribute msg
onPanDown =
    onHammerAttrsTrue "pandown"
