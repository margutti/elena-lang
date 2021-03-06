import system'collections;
import system'routines;
import system'drawing;
import system'winforms;

// --- IControl ---

public interface IControl
{
    get abstract object Control() {}
    
    get abstract string ID() {}
    
    abstract IControl retrieve(WindowHandle handle) {}
    
//    stacksafe readDimensionTo vint:aWidth vint:aHeight []
//    
//    stacksafe readLocationTo vint:x vint:y []
    
    abstract setRegion(int x, int y, int width, int height) {}
    
    abstract open() {}

    abstract click() {}

//    change []
        
    abstract close() {}
}

//public IControlOf<T>
//{
//    control = IControl::
//    {
//        control_object = $self.
//        
//        open [ $self open ]
//    
//        change [ $self change ]
//    
//        close [ $self close ]
//    
//        retrieve hwnd:aHandle = $self retrieve hwnd:aHandle.
//    
//        setDimension int:aWidth int:aHeight [ $self setDimension int:aWidth int:aHeight ]
//    
//        setLocation int:aWidth int:aHeight [ $self setLocation int:aWidth int:aHeight. ]
//    
//        readDimensionTo vint:aWidth vint:aHeight [ $self readDimensionTo vint:aWidth vint:aHeight ]
//    
//        readLocationTo vint:aWidth vint:aHeight [ $self readLocationTo vint:aWidth vint:aHeight ]
//    }.
//}

// --- BaseWindowControl ---

public abstract class BaseWinControl : BaseControl
{
    WindowHandle theHandle;

    protected constructor new()
        <= new()
    {
    }
    
    get Control() = self;
    
    IControl retrieve(WindowHandle handle)
    {
        if(nil == theHandle)
            { ^ nil };
            
        if(theHandle == handle)
            { ^ self };
            
        ^ nil 
    }

    internal abstract createHandle() {}            

    internal onCreate()
    {
        ifnot(theEnabled )
            { theHandle.setEnabled(0) };
    }

    click() {}
    
//    change []
    
    close()
    {
    }

    open()
    {
        if(nil != theHandle)
            { InvalidOperationException.new("The form is already open").raise() };
            
        self.createHandle();
        
        self.onCreate()
    }

//    opened = ($nil != theHandle).
    
    WindowHandle cast() = theHandle;

    bool Visible
    {
        set(bool v)
        {
            super.Visible := v;
            
            ifnot(nil == theHandle)
            {
                theHandle.setVisible(theVisible ? 5 : 0);
            }
        }
    }

    bool Enabled
    {
        set(bool value)
        {
            super.Enabled := value;
            
            ifnot(nil == theHandle)
            {
                int val := theEnabled ? -1 : 0;
                
                theHandle.setEnabled(val)
            }
            
        } 
    }
    
    string Caption
    {
        set(string s)
        {
            theCaption := s;
            //super.Caption := s;
            
            ifnot(nil == theHandle)
            {
                theHandle.setCaption(cast wide(s))
            }
        }
    
        set(wide s)
        {
            theCaption := s;
            //super.Caption := s;
            
            ifnot(nil == theHandle)
            {
                theHandle.setCaption(s)
            }
        }
        
        set(v)
        {
            self.Caption := cast string(v)
        }
    }
                                                                                                                                                                                                                                                                                        

//    append caption : aValue
//    [    
//        $self set caption($self caption + aValue wide)
//    ]

    get string Caption()
    {
        ifnot(nil == theHandle)
        {
            theCaption := theHandle.getCaption()
        };
            
        ^ theCaption
    }

    setRegion(int x, int y, int width, int height)
    {
        super.setRegion(x, y, width, height);
        
        ifnot(nil == theHandle)
        {
            theHandle.setPosition(x, y, 0, 0, SWP_NOSIZE);
            theHandle.setPosition(0, 0, width, height, SWP_NOMOVE)
        }        
    }
    
    refresh()
    {
        if(nil != theHandle)
            { theHandle.refresh() }
    }
    
    internal resize(WindowHandle hwnd, int width, int height)
    {
        theRegion.writeDimension(width, height)
    }  
}    

//// --- ControlCollection ---
//
//sealed class ControlCollection :: BaseControlCollection
//{
//    object theParent.
//    
//    constructor new : aParent
//        <= new;
//    [
//        theParent := aParent
//    ]
//    
//    append : aControl
//    [
//        $super append:(aControl control).
//        
//        aControl $set parent:theParent.
//        
//        if(theParent opened)
//        [
//            aControl open
//        ]
//    ]
//}

// --- BaseWinContainer ---

public abstract class BaseWinContainer : BaseWinControl
{
    List<IControl> theControls;
//    func1    theResize.
    
    protected constructor new()
        <= new()
    {
        theControls := new List<IControl>();
    }

//    set onResize:anAction
//    [
//        theResize := anAction func1.
//    ]

    IControl retrieve(WindowHandle handle)
    {
        if(theHandle == handle)
            { ^ self };

        int len := theControls.Length;
        IControl current;
        for (int i := 0, i < len, i += 1) {
            current := theControls[i].retrieve(handle);
            if (current != nil) {
                ^ current;
            }
        };
                            
        ^ nil
    }
        
    open()
    {
        super.open();
        
        int len := theControls.Length;
        for (int i := 0, i < len, i += 1) {
            theControls[i].open()
        }
    }
        
    close()
    {
        int len := theControls.Length;
        for (int i := 0, i < len, i += 1) {
            theControls[i].close()
        }
    }
    
    internal resize(WindowHandle hwnd, int width, int height)
    {
        super.resize(hwnd, width, height);

//        ifnot($nil == theResize)
//            [ theResize eval:$self ]
    }
    
    IControl findByID(string id)
        = theControls.seekEach:(x => x.ID == id);
        
    Controls = new
    {
        get generic()
        {
            string id := __received.MessageName.toPrintable();
            
            auto ctrl := self.findByID(id);
            if (ctrl != nil)
            {
                ^ ctrl.Control
            }
            else
            {
                ^ nil
            }
        }
    };        
}

// --- Frame ---

public sealed class Frame : BaseWinControl, interface<IControl>
{
    constructor new()
        <= new()
    {
    }
    
    internal createHandle()
    {
        WindowHandle parent := theParent;
        
        int styles := WS_CHILD || BS_GROUPBOX;
        if(theVisible)
            { styles := styles || WS_VISIBLE };
        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        WS_EX_TRANSPARENT,
                        ButtonClass, 
                        theCaption, 
                        styles,
                        x, y, width, height,
                        parent, 
                        CurrentInstance,
                        nil)
    }
}

// --- Label ---
public closed class Label : BaseWinControl, interface<IControl>
{
    constructor new()
        <= new()
    {
    }

    internal createHandle()
    {
        WindowHandle parent := theParent;
        
        int styles := WS_CHILD;
        if(theVisible)
            { styles := styles || WS_VISIBLE };
        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        0,
                        StaticClass, 
                        theCaption, 
                        styles,
                        x, y, width, height,
                        parent, 
                        CurrentInstance,
                        nil)
    }
}

//// --- Label ---
//
//class StaticLabel :: Label
//{
//    constructor new
//        <= new;
//    [
//    ]
//    
//    $createHandle
//    [
//        hwnd aParent := theParent hwnd.
//        if(0 == aParent)
//            [ InvalidOperationException new:"The parent window is closed"; raise ].
//        
//        int Styles := WS_CHILD || SS_SIMPLE.
//        if(theVisible)
//            [ Styles := Styles || WS_VISIBLE ].
//        
//        int anX := 0.
//        int anY := 0.
//        int aWidth := 0.
//        int aHeight := 0.
//        
//        theRegion read vint:anX vint:anY vint:aWidth vint:aHeight.
//        
//        theHandle := WindowHandle new int:0
//                        wide:StaticClass wide:(theCaption wide) int:Styles
//                        int:anX int:anY int:aWidth int:aHeight 
//                        hwnd:aParent hinstance:CurrentInstance object:$nil
//    ]
//}

// --- BaseEdit ---

abstract class BaseEdit : BaseWinControl
{
//    func1 theChanged.
//    
    protected constructor new()
        <= new()
    {
    }
    
//    set onChange:aFunction
//    [
//        theChanged := aFunction func1.
//    ]
//    
//    wide = $self caption.
//          
//    literal = $self caption.
          
    string Value = self.Caption;
    
//    append : aValue
//    [
//        $self set caption:($self caption + aValue wide).
//    ]
//    

    set Value(string value)
    {
        self.Caption := cast WideString(value);
    }
    
    internal updateStyles(ref int retVal)
    {
        int styles := retVal;
        
        if(theVisible)
            { styles := styles || WS_VISIBLE };
        if(theTabStop)
            { styles := styles || WS_TABSTOP };
            
        retVal := styles
    }
    
//    change 
//    [
//        if($nil != theChanged)
//            [ theChanged eval:$self ]
//    ]
}

// --- Edit ---

public sealed class Edit : BaseEdit, interface<IControl>
{
    constructor new()
        <= new()
    {
        theTabStop := true
    }
    
    internal createHandle()
    {
        WindowHandle parent := theParent;
        
        int styles := WS_CHILD || WS_BORDER;
        self.updateStyles(ref styles);
        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        WS_EX_CLIENTEDGE,
                        EditClass, 
                        theCaption, 
                        styles,
                        x, y, width, height,
                        parent, 
                        CurrentInstance,
                        nil)                        
    }
}

//// --- Memo ---
//
//sealed class Memo :: BaseEdit, icontrolof<memo>
//{
//    constructor new
//        <= new;
//    [
//        theTabStop := true
//    ]
// 
//    wide = $self caption.
//          
//    literal = $self caption.
//    
//    $createHandle
//    [
//        hwnd aParent := theParent hwnd.
//        
//        int Styles := WS_CHILD || WS_BORDER || ES_MULTILINE || ES_WANTRETURN || ES_AUTOHSCROLL || ES_AUTOVSCROLL || WS_VSCROLL || WS_HSCROLL.
//        $self $updateStyles vint:Styles.
//        
//        int anX := 0.
//        int anY := 0.
//        int aWidth := 0.
//        int aHeight := 0.
//        
//        theRegion read vint:anX vint:anY vint:aWidth vint:aHeight.
//        
//        theHandle := WindowHandle new int:WS_EX_CLIENTEDGE
//                        wide:EditClass wide:(theCaption wide) int:Styles
//                        int:anX int:anY int:aWidth int:aHeight 
//                        hwnd:aParent hinstance:CurrentInstance object:$nil.
//    ]
//}

// --- BaseButton ---

public abstract class BaseButton : BaseWinControl
{
    event Func1 onClick;
    
    protected constructor new()
        <= new()
    {
//        theTabStop := true.
    }
    
    internal updateStyles(ref int retVal)
    {
        int styles := retVal;
        
        if(theVisible)
            { styles := styles || WS_VISIBLE };
//        if(theTabStop)
//            [ Styles := Styles || WS_TABSTOP ].
            
        retVal := styles
    }
    
    click()
    {
        if(nil != onClick)
            { onClick(self) }
    }
}

// --- Button ---

public sealed class Button : BaseButton, interface<IControl>
{
    constructor new()
        <= new()
    {
    }

    internal createHandle()
    {
        WindowHandle parent := theParent;
        
        int styles := WS_CHILD || BS_PUSHBUTTON;
        self.updateStyles(ref styles);
        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        0,
                        ButtonClass, 
                        theCaption, 
                        styles,
                        x, y, width, height,
                        parent, 
                        CurrentInstance,
                        nil)                        
    }
}

// --- RadioButton ---

public closed class RadioButton : BaseButton, interface<IControl>
{
    bool theChecked;
    
    constructor new()
        <= new()
    {
        theChecked := false
    }
    
    constructor new(string caption)
        <= new()
    {
        theChecked := false;
        
        self.Caption := caption
    }
    
    bool Checked
    {
        get()
        {
            ifnot(nil == theHandle)
                { theChecked := theHandle.isChecked() };
                
            ^ theChecked
        }
        
        set(bool v)
        {
            theChecked := v;
            
            ifnot(nil == theHandle)
            {
                theHandle.setChecked(v ? BST_CHECKED : BST_UNCHECKED)
            }
        }
    }

    internal createHandle()
    {
        WindowHandle parent := theParent;
        
        int styles := WS_CHILD || BS_AUTORADIOBUTTON;
        self.updateStyles(ref styles);
        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        0,
                        ButtonClass, 
                        theCaption, 
                        styles,
                        x, y, width, height,
                        parent, 
                        CurrentInstance,
                        nil);
                        
        if(theChecked)
            { self.Checked := true }
    }
}

//// --- BaseList ---
//
//class BaseList :: BaseWinControl
//{
//    array_list theList.
//    
//    index_changed event onIndexChanged :: theChangeAction.
//    
//    constructor new
//        <= new;
//    [
//        theList := ArrayList new
//    ]
//    
//    items =
//    {
//        append : anObject as:aCaption
//        [
//            theList append:(KeyValue new key:aCaption value:anObject).
//            
//            self $appendItem wide:(aCaption wide)
//        ]
//    }.
//    
//    stacksafe $updateStyles vint:aRetVal
//    [
//        int Styles := aRetVal.
//        
//        if(theVisible)
//            [ Styles := Styles || WS_VISIBLE ].
//        if(theTabStop)
//            [ Styles := Styles || WS_TABSTOP ].
//            
//        aRetVal int := Styles.
//    ]
//}
//
//// --- Combobox ---
//
//sealed class Combobox :: BaseList, icontrolof<combobox>
//{
//    constructor new
//        <= new;
//    [
//    ]
//    
//    int vprop selected_index :: readSelectedIndexTo, setSelectedIndex.
//    
//    stacksafe readSelectedIndexTo vint:retVal
//    [
//        int index := system'external'USER32 SendMessageW int:theHandle int:CB_GETCURSEL int:0 int:0.
//        
//        retVal int := index
//    ]
//    
//    stacksafe setSelectedIndex int:index
//    [
//        system'external'USER32 SendMessageW int:theHandle int:CB_SETCURSEL int:index int:0.
//        
//        $self change
//    ]
//    
//    selected 
//    [
//        int index := $self selected_index.
//            
//        ^ theList getAt int:index.
//    ]
//    
//    change 
//    [
//        if($nil != theChangeAction)
//        [
//            int index := $self selected_index.
//            
//            theChangeAction onIndexChange:$self int:index.
//        ].
//    ]
//    
//    $appendItem wide:aCaption
//    [
//        if($nil == theHandle)
//            [ ^ $self ].
//        
//        theHandle sendMessage int:CB_ADDSTRING int:0 wide:aCaption.
//    ]
//    
//    $loadStrings
//    [
//        int aLength := theList length.
//        
//        int i := 0.
//        while(i < aLength)
//        [
//            var aKeyValue := theList getAt int:i.
//            
//            theHandle sendMessage int:CB_ADDSTRING int:0 wide:(aKeyValue key).
//            
//            i := i + 1
//        ]
//    ]
//    
//    $createHandle
//    [
//        hwnd aParent := theParent hwnd.
//        
//        int Styles := 0.
//        Styles := (WS_CHILD || CBS_DROPDOWNLIST).
//        $self $updateStyles vint:Styles.
//                
//        int anX := 0.
//        int anY := 0.
//        int aWidth := 0.
//        int aHeight := 0.
//        
//        theRegion read vint:anX vint:anY vint:aWidth vint:aHeight.
//        
//        theHandle := WindowHandle new int:0
//                        wide:ComboboxClass wide:emptyWideLiteralValue int:Styles
//                        int:anX int:anY int:aWidth int:aHeight 
//                        hwnd:aParent hinstance:CurrentInstance object:$nil.
//                        
//        $self $loadStrings
//    ]
//}

// --- Paintbox ---

class PaintboxListener : WindowCallback
{
    Paintbox theOwner;
    
    constructor(Paintbox owner)
    {
        theOwner := owner
    }
    
    onpaint(WindowHandle hwnd, ref int retVal)
    {
        theOwner.paint();
        
        retVal := 0
    }
    
    onsize(WindowHandle hwnd, int width, int height, ref int result)
    {
        theOwner.resize(hwnd, width, height);
        
        result := 0
    }
    
    ondestroy(WindowHandle hwnd, ref int result)
    {
        theOwner.destroy();
        
        super.ondestroy(hwnd, ref result)
    }
}

//limited closure class PaintAction
//{
//    closure(object sender, canvas canvas) []
//}

public closed class Paintbox : BaseWinControl, interface<IControl>
{
    Canvas  theCanvas;
    
    event Func<object,Canvas,object> onPaint;
    
    constructor new()
        <= new()
    {
        theCanvas := new Canvas()
    }

    internal destroy()
    {
        theCanvas.free()
    }
 
    internal paint()
    {
        PAINTSTRUCT struct := new PAINTSTRUCT();
        
        struct.begin(theHandle);
        HDC dc := struct.HDC;
        
        theCanvas.open(dc);
        
        onPaint.?(self, theCanvas);

        theCanvas.close();

        struct.end(theHandle)
    }
 
//    stacksafe $resize hwnd:aControl int:aWidth int:aHeight
//    [
//    ]
// 
//    $resize int:aWidth int:aHeight
//    [
//        $self $resize hwnd:theHandle int:aWidth int:aHeight.
//    ]
 
    internal createHandle()
    {
        WindowHandle parent := theParent;

        int styles := WS_CHILD;
        if(theVisible)
            { styles := styles || WS_VISIBLE };
                        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        WS_EX_TRANSPARENT,
                        PaintboxClass,
                        theCaption,
                        styles,
                        x, y, width, height,
                        parent,
                        CurrentInstance,
                        new PaintboxListener(self))
    }
}

public sealed class Imagebox : Paintbox
{
    HBITMAP  theImage;
    HDC      theImageDC;
    bool     theNeedToRefresh;
    
    constructor new()
        <= new()
    {
        theNeedToRefresh := false
    }

    internal destroy()
    {
        super.destroy();
        
        theImage.free();
        theImageDC.free()
    }
    
    internal paint()
    {
        if(theNeedToRefresh)
            { self.refresh() };
        
        PAINTSTRUCT struct := new PAINTSTRUCT();
        
        struct.begin(theHandle);
        
        theRegion.readDimensionTo(ref int width, ref int height);
        
        HDC dc := struct.HDC;
        
        dc.copy(0, 0, width, height, theImageDC, 0, 0, SRCCOPY);
//        int err := system'external'KERNEL32 GetLastError.
                
        struct.end(theHandle)
    }
 
    refresh()
    {
        if(nil == theHandle)
            { ^ self };
        
        onPaint.?(self, theCanvas);

        super.refresh();
        theNeedToRefresh := false
    }
 
    internal resize(WindowHandle handle, int width, int height)
    {
        ifnot(nil == theImage)
        {
            theImage.free();
            theImageDC.free()
        };
            
        HDC dc := handle.HDC;
            
        theImage := HBITMAP.create(dc, width, height);
        theImageDC := HDC.newCompatible(dc);
        theImage.select(theImageDC);

        theCanvas.open(theImageDC);

        theNeedToRefresh := true
    }
}

// --- BasePanel ---

public abstract class BasePanel : BaseWinContainer
{
    Frame theFrame;
    
    protected constructor new()
        <= new()
    {
        theFrame := Frame.new();
        
        // NOTE : a frame should be the first element
        self.appendControlInternal:theFrame
    }
    
    internal appendControlInternal(BaseControl control)
    {
        control.Parent := self;
        
        theControls.append(control)        
    }
    
    internal appendControlInternal(ImageList control)
    {
        control.Parent := self;
        
        theControls.append(control)        
    }
    
    int Width
    {
        set(int v)
        {
            super.Width := v;
            
            theFrame.Width := v
        }        
    }
    
    int Height
    {
        set(int h)
        {
            super.Height := h;
            
            theFrame.Height := h
        }
    }
            
    setRegion(int x, int y, int width, int height)
    {
        super.setRegion(x, y, width, height);
        
        theFrame.setRegion(0, 0, width, height);
    }
    
    string Caption
    {
        set(string caption)
        {
            theFrame.Caption := caption
        }
        
        set(wide caption)
        {
            theFrame.Caption := caption
        }
    }    
    
    internal resize(WindowHandle handle, int width, int height)
    {
        theFrame.Width := width;
        theFrame.Height := height
    }    
}

// --- Panel ---

class PanelListener : WindowCallback
{
    Panel theOwner;
    
    constructor(Panel owner)
    {
        theOwner := owner
    }
    
    onsize(WindowHandle hwnd, int width, int height, ref int result)
    {
        theOwner.resize(hwnd, width, height);
        
        result := 0
    }
    
//    onclick hwnd:aHandle vint:aResult
//    [
//        var aControl := theOwner retrieve hwnd:aHandle.
//        if($nil != aControl)
//            [ aControl click ].
//        
//        $super onclick hwnd:aHandle vint:aResult.
//    ]
//    
//    onchange hwnd:aHandle vint:aResult
//    [
//        var aControl := theOwner retrieve hwnd:aHandle.
//        if($nil != aControl)
//            [ aControl change ].
//        
//        $super onchange hwnd:aHandle vint:aResult.
//    ]
}

public sealed class Panel : BasePanel, interface<IControl>
{
    constructor new()
        <= new()
    {
    }
    
    appendControl(BaseControl control)
    {
        self.appendControlInternal(control);
    }
    appendControl(control)
    {
        self.appendControlInternal(control);
    }
    
    internal createHandle()
    {
        WindowHandle parent := theParent;

        int styles := WS_CHILD || WS_CLIPSIBLINGS;
        if(theVisible)
            { styles := styles || WS_VISIBLE };
                        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        WS_EX_CONTROLPARENT,
                        PanelClass,
                        theCaption,
                        styles,
                        x, y, width, height,
                        parent,
                        CurrentInstance,
                        new PanelListener(self))
                        
    }
}

// --- RadioButtonGroup ---

class RadioButtonGroupListener : WindowCallback
{
    RadioButtonGroup theOwner;
    
    onclick(WindowHandle hwnd, ref int retVal)
    {
        theOwner.onClick(hwnd);
        
        retVal := 0
    }

    onsize(WindowHandle hwnd, int width, int height, ref int result)
    {
        theOwner.resize(hwnd, width, height);
        
        result := 0
    }
    
    constructor(RadioButtonGroup owner)
    {
        theOwner := owner
    }
}

public sealed class RadioButtonGroup : BasePanel, interface<IControl>
{
    int   theSelected;
    event Func1 onIndexChanged;
    
    constructor new()
        <= new()
    {
        theSelected := -1
    }

    int SelectedIndex
    {
        get() = theSelected;
        
        set(int n)
        {
            ifnot(-1 == theSelected)
                { self.setChecked(false) };
            
            theSelected := n;
        
            self.setChecked(true);
        
            onIndexChanged.?(self);
        }
    }

    private setChecked(value)
    {
        int len := theControls.Length;
        IControl current;
        for (int i := 1, i < len, i += 1) {
            current := theControls[i];
            int index := i - 1;
            if (index == theSelected)
            {
                current.Control.Checked := value;
                
                ^ self
            }
        };
    }

    appendItem(string s)
    {
        self.appendControlInternal(RadioButton.new(s));
    }

    setRegion(int x, int y, int width, int height)
    {
        super.setRegion(x, y, width, height);
        
        self.resize()
    }

    internal onClick(WindowHandle handle)
    {
        var retVal := nil;
        int len := theControls.Length;
        IControl current;
        for (int i := 1, i < len, i += 1) {
            current := theControls[i];            
            
            retVal := current.retrieve(handle);
            if(nil != retVal)
            {
                int index := i - 1;
                theSelected := index;
                
                onIndexChanged.?(self);
                
                ^ self
            }
        }
    }

    internal resize()
    {
        int width := theRegion.Width;
        int height := theRegion.Height;
        
        self.resize(theHandle, width, height)
    }
            
    internal resize(WindowHandle handle, int width, int height)
    {
        int len := theControls.Length;
        IControl current;
        for (int i := 1, i < len, i += 1) {
            current := theControls[i];
            int index := i - 1;
            
            current.setRegion(4, 18 + index * 20, width - 6, 20);
        };
        
        super.resize(handle, width, height)
    }
    
    internal createHandle()
    {
        WindowHandle parent := theParent;

        int styles := WS_CHILD || WS_CLIPSIBLINGS;
        if(theVisible)
            { styles := styles || WS_VISIBLE };
                        
        theRegion.read(ref int x, ref int y, ref int width, ref int height);
        
        theHandle := new WindowHandle(
                        WS_EX_CONTROLPARENT,
                        PanelClass,
                        theCaption,
                        styles,
                        x, y, width, height,
                        parent,
                        CurrentInstance,
                        new RadioButtonGroupListener(self))
                                                
//        if((theSelected != -1)and:($nil != theIndexChanged))
//            [ theIndexChanged eval:$self ]
    }
}

// --- ImageList ---

public sealed class ImageList : Object, interface<IControl>
{
    Dimension    theSize;
    object       theParent;
    List<Image>  theImages; 
    int          theIndex;
 
    constructor new()
    {
        theIndex := 0;
        theImages := new List<Image>();
        
        theSize :=  new Dimension(50, 50)
    }

    setRegion(int x, int y, int width, int height)
    {
        theSize.Width := width;
        theSize.Height := height
    }

     prop string ID;
         
//    assign : aControl
//       <= assign paintbox:(aControl paintbox).
 
    assign(Paintbox paintbox)
    {
        paintbox.onPaint := (object sender, Canvas canvas)
        {
            int width := theSize.Width;
            int height := theSize.Height;
            
            auto image := theImages[theIndex];
            
            canvas.write(image, 0, 0, width, height)
        }
    }

    int SelectedIndex
    {
        get() = theIndex;
        
        set(int n)
        {
            theIndex := n
        }
    }

    IControl retrieve(WindowHandle handle) 
    {
        ^ nil
    }
    
    click() {}

    Parent = theParent;    

    set internal Parent(object o)
    {
        theParent := o
    }

    appendImage(string path)
    {        
        theImages.append(Image.load(path, theSize))
    }
    
    open()
    {
        WindowHandle parent := theParent;
        HDC parentDC := parent.HDC;        

        int len := theImages.Length;
        for (int i := 0, i < len, i += 1) {
            theImages[i].open(parentDC)
        }
    }
    
    close()
    {
        int len := theImages.Length;
        for (int i := 0, i < len, i += 1) {
            theImages[i].free()
        }
    }    
}

//// --- DockingBox ---
//
//sealed class DockingBox
//{
//    object  theParent.
//    control theLeft.
//    control theRight.
//    control theTop.
//    control theBottom.
//    control theClient.
//
//    constructor new
//    [
//    ]
// 
//    assign client:aControl
//    [
//        theClient := aControl control.
//    ]
//
//    assign left:aControl
//    [
//        theLeft := aControl control.
//    ]
//
//    assign right:aControl
//    [
//        theRight := aControl control.
//    ]
//
//    assign top:aControl
//    [
//        theTop := aControl control.
//    ]
//
//    assign bottom:aControl
//    [
//        theBottom := aControl control.
//    ]
//   
//    control = IControl::
//    {
//        control_object = $self.
// 
//        open [ $self open ]
//          
//        close [ $self close ]
//          
//        retrieve hwnd:aHandle = $nil.
//    }.
// 
//    $set parent:aParent
//    [
//        theParent := aParent.
//        
//        theParent set onResize: (:control)
//        [
//            self refresh
//        ].
//    ]
//
//    open
//    [
//        $self refresh.
//    ]
//     
//    close
//    [
//    ]        
//              
//    refresh
//    [
//        int tmp := 0.
//        
//        dimension theSize := theParent dimension.
//
//        int height := 0.
//        int width := 0.
//        int x := 0.
//        int y := 0.
//        int aTotalWidth := 0.
//        int aTotalHeight := 0.
//        theSize read vint:aTotalWidth vint:aTotalHeight.
//
//        // Bottom
//        if($nil != theBottom)
//        [
//            theBottom readDimensionTo vint:tmp vint:height.
//            theBottom setDimension int:aTotalWidth int:height.
//            
//            aTotalHeight := aTotalHeight - height
//        ].
//        
//        // Top
//        if($nil != theTop)
//        [
//            
//            theTop readDimensionTo vint:tmp vint:height.
//            theTop setDimension int:aTotalWidth int:height.
//            
//            aTotalHeight := aTotalHeight - height.
//            
//            y := height
//        ].
//        
//        // Left
//        if($nil != theLeft)
//        [
//            theLeft readDimensionTo vint:width vint:tmp.
//            theLeft setDimension int:width int:aTotalHeight.
//            
//            aTotalWidth := aTotalWidth - width.
//            
//            x := width
//        ].
//        
//        // Right
//        if($nil != theRight)
//        [
//            theRight readDimensionTo vint:width vint:tmp.
//            theRight setDimension int:width int:aTotalHeight.
//            
//            aTotalWidth := aTotalWidth - width
//        ].
//
//        // Client
//        if($nil != theClient)
//        [
//            theClient setDimension int:aTotalWidth int:aTotalHeight.
//            theClient setLocation int:x int:y.            
//        ].
//        
//        x := x + aTotalWidth.
//        y := y + aTotalHeight.
//
//        if($nil != theRight)        
//            [ theRight setLocation int:x int:height ].
//            
//        if($nil != theBottom)
//            [ theBottom setLocation int:0 int:y ].
//    ]    
//}
