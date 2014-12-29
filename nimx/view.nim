import typetraits
import types
import context

export types


type EventKind = enum
    ekMouseMove, ekMouseAction

type MouseEvent = tuple[position: Point, kind: EventKind, state: ButtonState]

type
    View* = ref TView
    TView = object of RootObj
        frame*: Rect
        bounds*: Rect
        subviews: seq[View]
        superview: View

method init*(v: View, frame: Rect) =
    v.frame = frame
    v.bounds = newRect(0, 0, frame.width, frame.height)
    v.subviews = @[]

proc newView*(frame: Rect): View =
    result.new()
    result.init(frame)

proc convertCoordinates*(p: Point, fromView, toView: View): Point =
    if fromView == toView: return p
    if fromView == nil: # p is screen coordinates
        discard
    return p

proc convertCoordinates*(r: Rect, fromView, toView: View): Rect =
    r

method removeSubview*(v: View, s: View) =
    for i, ss in v.subviews:
        if ss == s:
            v.subviews.del(i)
            break

method removeFromSuperview*(v: View) =
    if v.superview != nil:
        v.superview.removeSubview(v)

method addSubview*(v: View, s: View) =
    if s.superview != v:
        s.removeFromSuperview()
        v.subviews.add(s)

proc recursiveDrawSubviews*(view: View)

method draw*(view: View) =
    let c = currentContext()
    c.fillColor = newColor(0, 0, 1)
    c.drawRect(view.bounds)

proc drawSubviews(view: View) {.inline.} =
    let c = currentContext()
    for i in view.subviews:
        var tmpTransform = c.transform
        tmpTransform.translate(newVector3(i.frame.x, i.frame.y, 0))
        let oldTransform = c.setScopeTransform(tmpTransform)
        i.recursiveDrawSubviews()
        c.revertTransform(oldTransform)

proc recursiveDrawSubviews*(view: View) =
    view.draw()
    view.drawSubviews()

method handleMouseEventRecursive(v: View, e: MouseEvent, translatedCoords: Point): bool =
    for i in v.subviews:
        discard