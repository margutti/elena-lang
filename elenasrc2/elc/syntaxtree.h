//---------------------------------------------------------------------------
//		E L E N A   P r o j e c t:  ELENA Compiler
//
//		This file contains ELENA Engine Syntax Tree classes
//
//                                              (C)2005-2016, by Alexei Rakov
//---------------------------------------------------------------------------

#ifndef syntaxTreeH
#define syntaxTreeH 1

namespace _ELENA_
{

// --- SyntaxType ---

enum LexicalType
{
   lxParameter       = 0x10000,
   lxObjectMask      = 0x08000,
   lxCodeScopeMask   = 0x04000,
   lxExprMask        = 0x0C000,
   lxReferenceMask   = 0x40000,

   lxEnding          = -1,
   lxNone            = 0x00000,

   // scopes
   lxRoot            = 0x00001,
   lxClass           = 0x0000E,
   lxSymbol          = 0x00011,
   lxClassMethod     = 0x00016,
   lxCode            = 0x0001A,
   lxStatic          = 0x00022,
   lxConstructor     = 0x00024,

   // parameters
   lxEOF             = 0x18003, // indicating closing code bracket
   lxLiteral         = 0x18004,
   lxIdentifier      = 0x18005,
   lxPrivate         = 0x18006,
   lxReference       = 0x18007,
   lxInteger         = 0x18008,
   lxHexInteger      = 0x18009,
   lxReal            = 0x1800A,
   lxCharacter       = 0x1800B,
   lxLong            = 0x1800C,
   lxWide            = 0x1800D,

   lxImporting       = 0x08101,
   lxSymbolReference = 0x18107,
   lxLocal           = 0x0810A, // arg - offset
   lxConstantClass   = 0x18112, // arg - reference
   lxNil             = 0x08117,

   lxCalling         = 0x04007,   // sending a message, arg - message
   lxExpression      = 0x0C012,
   lxNewFrame        = 0x04024, // if argument -1 - than with presaved message
   lxCreatingClass   = 0x0C025, // arg - count
   lxCreatingStruct  = 0x0C026, // arg - size
   lxDispatching     = 0x04036, // dispatching a message, optional arg - message

   // attributes
   lxSourcePath      = 0x20001,
   lxCol             = 0x20002,
   lxRow             = 0x20003,
   lxLength          = 0x02004,
   lxBreakpoint      = 0x20005,
   lxImport          = 0x20006,
   lxReserved        = 0x20007,
   lxParamCount      = 0x20008,
   lxClassFlag       = 0x20009, // class fields
   lxTarget          = 0x6000A, // arg - reference
   lxMessageVariable = 0x2000B, // debug info only
   lxSelfVariable    = 0x2000C, // debug info only
   lxMessage         = 0x1044A, // arg - message

//   lxObjectMask      = 0x00100,
//   lxExpressionMask  = 0x00200,
//   lxAttrMask        = 0x00800,
//   lxPrimitiveOpMask = 0x01000,
//   lxSimpleMask      = 0x04000,   // idicates if the implementation does not affect base / other registers
//   lxMessageMask     = 0x10000,
//   lxReferenceMask   = 0x20000,
//   lxSubjectMask     = 0x40000,
//   lxConstantMask    = 0x80000,

//   lxInvalid         = 0x00001,
//   lxIdle            = 0x00003,
//
//   lxNested = 0x00101, // arg - count
//   lxStruct = 0x00102, // arg - count
//   lxSymbol = 0x20103, // arg - reference
//   lxConstantSymbol = 0x24104, // arg - reference
//   lxField = 0x00105, // arg - offset
//   lxStaticField = 0x20106, // arg - reference
//   lxFieldAddress = 0x00107, // arg - offset
//   lxLocalAddress = 0x04108, // arg - offset
//   lxBlockLocalAddr = 0x04109, // arg - offset
//   lxBlockLocal = 0x0410B, // arg - offset
//   lxConstantString = 0x8410C, // arg - reference
//   lxConstantWideStr = 0x8410D, // arg - reference
//   lxConstantChar = 0x8410E, // arg - reference
//   lxConstantInt = 0x8410F, // arg - reference
//   lxConstantLong = 0x84110, // arg - reference
//   lxConstantReal = 0x84111, // arg - reference
//   lxMessageConstant = 0x24113, // arg - rererence
//   lxExtMessageConstant = 0x24114, // arg -reference
//   lxSignatureConstant = 0x24115, // arg - reference
//   lxVerbConstant = 0x24116, // arg - reference
//   lxCurrent = 0x04118, // arg -offset
//   lxResult = 0x04119, // arg -offset
//   lxResultField = 0x0411A, // arg -offset
//   lxCurrentMessage = 0x0411B,
//   lxThisLocal = 0x0411C,
//   lxCurrentField = 0x0411D, // arg -offset
//   lxConstantList = 0x2411E, // arg - reference
//
//   lxBoxing          = 0x00302,   // boxing of the argument, arg - size
//   lxCondBoxing      = 0x00303,   // conditional boxing, arg - size
//   lxUnboxing        = 0x00304,   // boxing and unboxing of the argument, arg - size
//   lxArgBoxing       = 0x00305,   // argument list boxing, arg - size
//   lxTypecasting     = 0x10306,   // typecasting, arg - message
//   lxDirectCalling   = 0x10308,   // calling a method, arg - message
//   lxSDirctCalling   = 0x10309,   // calling a virtual method, arg - message
//   lxResending       = 0x1030A,   // resending a message, optional arg - message
//   lxTrying          = 0x0030C,   // try-catch expression
//   lxAlt             = 0x0030D,   // alt-catch expression
//   lxLocking         = 0x0030E,   // lock expression
//   lxBranching       = 0x0030F,   // branch expression
//   lxSwitching       = 0x00310,
//   lxLooping         = 0x00311,
//   lxReturning       = 0x00312,
//   lxThrowing        = 0x00313,
//   lxStdExternalCall = 0x20314,  // calling an external function, arg - reference
//   lxExternalCall    = 0x20315,  // calling an external function, arg - reference
//   lxCoreAPICall     = 0x20316,  // calling an external function, arg - reference
//   lxIntExtArgument  = 0x00317,
//   lxExtArgument     = 0x00318,
//   lxExtInteranlRef  = 0x00319,
//   lxInternalCall    = 0x2031A,  // calling an internal function, arg - reference
//   lxMember          = 0x0031B,  // a collection member, arg - offset
//   lxOuterMember     = 0x0031C,  // a collection member, arg - offset
//   lxAssigning       = 0x0031D,  // an assigning expression, arg - size
//   lxArgUnboxing     = 0x0031E,
//   lxIf              = 0x2031F,  // optional arg - reference
//   lxElse            = 0x20320,  // optional arg - reference
//   lxOption          = 0x00321,
//   lxFieldExpression = 0x00322,
//   lxLocalUnboxing   = 0x00323, // arg - size
//   lxExternFrame     = 0x00327,
//   lxNewOp           = 0x20328,
//   lxBody            = 0x00329,
//
//   lxOp              = 0x0032A, // generic operation, arg - operation id 
//   lxBoolOp          = 0x0032B, // arg - operation id
//   lxNilOp           = 0x0032C, // arg - operation id
//   lxIntOp           = 0x0132D, // arg - operation id
//   lxLongOp          = 0x0132E, // arg - operation id
//   lxRealOp          = 0x0132F, // arg - operation id
//   lxIntArrOp        = 0x01330, // arg - operation id
//   lxByteArrOp       = 0x01331, // arg - operation id
//   lxShortArrOp      = 0x01332, // arg - operation id
//   lxArrOp           = 0x01333, // arg - operation id
//   lxBinArrOp        = 0x01334, // arg - operation id
//
//   lxVariable        = 0x00427, // debug info only if lxFrameAttr is included
//   lxIntVariable     = 0x00428,
//   lxLongVariable    = 0x00429,
//   lxReal64Variable  = 0x0042A,
//   lxBytesVariable   = 0x0042B,
//   lxShortsVariable  = 0x0042C,
//   lxIntsVariable    = 0x0042D,
//   lxBinaryVariable  = 0x0042E,
//   lxParamsVariable  = 0x0042F,
//   lxReleasing       = 0x00432,
//   lxTemplateTarget  = 0x00434, // template target pseudo variable
//   lxBinarySelf      = 0x00435, // debug info only
//
//   lxCallTarget      = 0x20442, // arg - reference
//   lxType            = 0x40443, // arg - subject
//   //lxSubject         = 0x40804, // arg - subject
//   lxStacksafe       = 0x00445,
//   lxTempLocal       = 0x00446,
//   lxOverridden      = 0x00447,
//   lxIfValue         = 0x20448, // arg - reference
//   lxElseValue       = 0x20449, // arg - reference
//   lxEmbeddable      = 0x0044B,
//   lxSize            = 0x0044C,
//   lxSubject         = 0x4044F,
//
//   lxStaticAttr      = 0x00820,
//   lxConstAttr       = 0x00821,
//   lxPreloadedAttr   = 0x00822,
//   lxClassMethodAttr = 0x00807,
//   //lxClassMethodOpt  = 0x04008,
//   lxWarningMask     = 0x00809,
//
//   lxTerminal        = 0x02005,
//   lxLevel           = 0x02006,
//   lxClassName       = 0x02007, // arg - reference
//   lxValue           = 0x02008,
//   lxFrameAttr       = 0x02009,
//   lxSourcePath      = 0x0200A,
//
//   //lxClassArray      = 0x04003,
//   lxClassField      = 0x04005,
//
//   lxTemplate         = 0x4000B,
//   lxTemplateField    = 0x0000C,
//   lxTemplateFieldType= 0x0000D,
//   lxTemplateSubject  = 0x0000E,
//   lxTemplateMethod   = 0x0000F,
//   lxNestedTemplate   = 0x00010, // arg - count
//   lxNestedTemplateOwner  = 0x00011, // indicates the nested template owner
//   lxNestedTemplateParent = 0x20812,
//   lxTemplateParam    = 0x00013,
//   lxClass            = 0x00014,
//   lxTemplateType     = 0x40015,
//   lxTargetMethod     = 0x10016
};

// --- SyntaxTree ---

class SyntaxTree
{
   MemoryDump _body;

public:
   // --- SyntaxWriter ---

   class Writer
   {
      MemoryWriter  _writer;
      Stack<size_t> _bookmarks;

   public:
      int setBookmark(size_t position)
      {
         _bookmarks.push(position);
         return _bookmarks.Count();
      }

      int newBookmark()
      {
         _bookmarks.push(_writer.Position());

         return _bookmarks.Count();
      }

      void removeBookmark()
      {
         _bookmarks.pop();
      }

      void clear()
      {
         _writer.seek(0);
         _bookmarks.clear();
      }

//      void clear(int bookmark)
//      {
//         size_t position = (bookmark == 0) ? _bookmarks.peek() : *_bookmarks.get(_bookmarks.Count() - bookmark);
//
//         _writer.seek(position);
//         _bookmarks.clear();
//      }

      void insert(int bookmark, LexicalType type, ref_t argument);
      void insert(int bookmark, LexicalType type, ident_t argument);
//      void insert(int bookmark, LexicalType type)
//      {
//         insert(type, 0);
//      }
      void insert(LexicalType type, ref_t argument)
      {
         insert(0, type, argument);
      }
      void insert(LexicalType type)
      {
         insert(0, type, 0);
      }
      //void insertChild(int start_bookmark, int end_bookmark, LexicalType type, ref_t argument)
      //{
      //   insert(end_bookmark, lxEnding, 0);
      //   insert(start_bookmark, type, argument);
      //}
      void insertChild(int bookmark, LexicalType type, ref_t argument)
      {
         insert(bookmark, lxEnding, 0);
         insert(bookmark, type, argument);
      }
      void insertChild(int bookmark, LexicalType type, ident_t argument)
      {
         insert(bookmark, lxEnding, 0);
         insert(bookmark, type, argument);
      }
      //      void insertChild(LexicalType type, ref_t argument)
//      {
//         insert(lxEnding, 0);
//         insert(type, argument);
//      }

      void newNode(LexicalType type, ref_t argument);
      void newNode(LexicalType type, ident_t argument);
      void newNode(LexicalType type)
      {
         newNode(type, 0u);
      }
      void appendNode(LexicalType type, ref_t argument)
      {
         newNode(type, argument);
         closeNode();
      }
      void appendNode(LexicalType type, ident_t argument)
      {
         newNode(type, argument);
         closeNode();
      }
      void appendNode(LexicalType type)
      {
         newNode(type);
         closeNode();
      }

      void closeNode();

      Writer(SyntaxTree& tree)
         : _writer(&tree._body)
      {
      }

      /// parameter : appendMode - when true, the ending node is removed
      //Writer(SyntaxTree& tree/*, bool appendMode*/)
      //   : _writer(&tree._body), _stringWriter(&tree._strings)
      //{
//         if (appendMode && tree._body.Length() >= 12) {
//            tree._body.trim(tree._body.Length() - 12);
//            _writer.seekEOF();
//         }
//            
//      }
   };

//   struct NodePattern;

   // --- Node ---
   class Node
   {
      friend class SyntaxTree;

      SyntaxTree*   tree;
      size_t        position;

      Node(SyntaxTree* tree, size_t position, LexicalType type, ref_t argument, int length);

   public:
      LexicalType   type;
      ref_t         argument;
      int           argLength;   // if argLength is not zero - it contains the length of the argument string

//      SyntaxTree* Tree()
//      {
//         return tree;
//      }

      ident_t identifier()
      {
         if (argLength > 0) {
            return (const char*)(tree->_body.get(position));
         }
         else return NULL;
      }

      operator LexicalType() const { return type; }

      bool operator == (LexicalType type)
      {
         return this->type == type;
      }
      bool operator != (LexicalType type)
      {
         return this->type != type;
      }

      void operator = (LexicalType type)
      {
         this->type = type;

         MemoryReader reader(&tree->_body, position - 12);

         *(int*)(reader.Address()) = (int)type;
      }

      void setArgument(ref_t argument)
      {
         this->argument = argument;

         MemoryReader reader(&tree->_body, position - 8);
         *(int*)(reader.Address()) = (int)argument;
      }

      Node firstChild() const
      {
         if (tree != NULL) {
            return tree->readFirstNode(position + argLength);
         }
         else return Node();
      }

      Node firstChild(LexicalType mask) const
      {
         Node node = firstChild();

         while (node != lxNone && !test(node.type, mask))
            node = node.nextNode();

         return node;
      }

      Node findNext(LexicalType mask) const
      {
         Node node = *this;

         while (node != lxNone && !test(node.type, mask))
            node = node.nextNode();

         return node;
      }

//      Node lastChild() const
//      {
//         Node current = firstChild();
//         if (current != lxNone) {
//            while (current.nextNode() != lxNone) {
//               current = current.nextNode();
//            }
//         }
//         return current;
//      }

      Node nextNode() const
      {
         return tree->readNextNode(position + argLength);
      }

//      Node prevNode() const
//      {
//         return tree->readPreviousNode(position);
//      }
//
//      Node parentNode() const
//      {
//         return tree->readParentNode(position);
//      }

      void insertNode(LexicalType type, int argument = 0)
      {
         tree->insertNode(position + argLength, type, argument);
      }

      void insertNode(LexicalType type, ident_t argument)
      {
         tree->insertNode(position + argLength, type, argument);
      }

      Node appendNode(LexicalType type, int argument = 0)
      {
         int end_position = tree->seekNodeEnd(position + argLength);

         return tree->insertNode(end_position, type, argument);
      }

//      void injectNode(LexicalType type, int argument = 0)
//      {
//         int start_position = position;
//         int end_position = tree->seekNodeEnd(position);
//         
//         tree->insertNode(start_position, end_position, type, argument);
//      }
//
//      Node findPattern(NodePattern pattern)
//      {
//         return tree->findPattern(*this, 1, pattern);
//      }

      Node findChild(LexicalType type)
      {
         Node current = firstChild();

         while (current != lxNone && current != type) {
            current = current.nextNode();
         }

         return current;
      }
      Node findChild(LexicalType type1, LexicalType type2)
      {
         Node current = firstChild();
      
         while (current != lxNone && current != type1) {
            if (current == type2)
               return current;
      
            current = current.nextNode();
         }
      
         return current;
      }

      Node()
      {
         type = lxNone;
         argument = 0;
         argLength = 0;

         tree = NULL;
      }
   };

//   struct NodePattern
//   {
//      LexicalType type;
//      LexicalType alt_type1;
//
//      bool match(Node node)
//      {
//         return node.type == type || node.type == alt_type1;
//      }
//
//      NodePattern()
//      {
//         type = lxNone;
//         alt_type1 = lxInvalid;
//      }
//      NodePattern(LexicalType type)
//      {
//         this->type = type;
//         this->alt_type1 = lxInvalid;
//      }
//      NodePattern(LexicalType type1, LexicalType type2)
//      {
//         this->type = type1;
//         this->alt_type1 = type2;
//      }
//   };

private:
   Node read(StreamReader& reader);

public:
   static void copyNode(Writer& writer, Node node);

//   static int countChild(Node node, LexicalType type)
//   {
//      int counter = 0;
//      Node current = node.firstChild();
//
//      while (current != lxNone) {
//         if (current == type)
//            counter++;
//
//         current = current.nextNode();
//      }
//
//      return counter;
//   }
//
//   static int countChild(Node node, LexicalType type1, LexicalType type2)
//   {
//      int counter = 0;
//      Node current = node.firstChild();
//
//      while (current != lxNone) {
//         if (current == type1 || current == type2)
//            counter++;
//
//         current = current.nextNode();
//      }
//
//      return counter;
//   }
//
//
//   static Node findMatchedChild(Node node, int mask)
//   {
//      Node current = node.firstChild();
//
//      while (current != lxNone && !test(current.type, mask)) {
//         current = current.nextNode();
//      }
//
//      return current;
//   }
//
//   static Node findSecondMatchedChild(Node node, int mask)
//   {
//      Node current = node.firstChild();
//
//      bool first = true;
//      while (current != lxNone) {
//         if (test(current.type, mask)) {
//            if (first) {
//               first = false;
//            }
//            else return current;
//         }
//         current = current.nextNode();
//      }
//
//      return current;
//   }
//
//   static Node findChild(Node node, LexicalType type1, LexicalType type2, LexicalType type3)
//   {
//      Node current = node.firstChild();
//
//      while (current != lxNone && current != type1) {
//         if (current == type2 || current == type3)
//            return current;
//
//         current = current.nextNode();
//      }
//
//      return current;
//   }
//
//   static Node findChild(Node node, LexicalType type1, LexicalType type2, LexicalType type3, LexicalType type4)
//   {
//      Node current = node.firstChild();
//
//      while (current != lxNone && current != type1) {
//         if (current == type2 || current == type3 || current == type4)
//            return current;
//
//         current = current.nextNode();
//      }
//
//      return current;
//   }
//
//   static Node findChild(Node node, LexicalType type1, LexicalType type2, LexicalType type3, LexicalType type4, LexicalType type5)
//   {
//      Node current = node.firstChild();
//
//      while (current != lxNone && current != type1) {
//         if (current == type2 || current == type3 || current == type4 || current == type5)
//            return current;
//
//         current = current.nextNode();
//      }
//
//      return current;
//   }
//
//   static bool existChild(Node node, LexicalType type)
//   {
//      Node child = findChild(node, type);
//
//      return child == type;
//   }
//
//   static bool existChild(Node node, LexicalType type1, LexicalType type2)
//   {
//      Node child = findChild(node, type1, type2);
//
//      return child != lxNone;
//   }
//
//   _Memory* Strings() { return &_strings; }

   Node readRoot();
   Node readFirstNode(size_t position);
   Node readNextNode(size_t position);
//   Node readPreviousNode(size_t position);
//   Node readParentNode(size_t position);

   size_t seekNodeEnd(size_t position);

   Node insertNode(size_t position, LexicalType type, int argument);
   Node insertNode(size_t position, LexicalType type, ident_t argument);
//   Node insertNode(size_t start_position, size_t end_position, LexicalType type, int argument);
//
//   bool matchPattern(Node node, int mask, int counter, ...);
//   Node findPattern(Node node, int counter, ...);
//
//   ref_t writeString(ident_t string)
//   {
//      MemoryWriter writer(&_strings);
//      ref_t position = writer.Position();
//
//      writer.writeLiteral(string);
//
//      return position;
//   }
//
//   void save(_Memory* section)
//   {
//      MemoryWriter writer(section);
//
//      writer.writeDWord(_body.Length());
//      writer.write(_body.get(0), _body.Length());
//
//      writer.writeDWord(_strings.Length());
//      writer.write(_strings.get(0), _strings.Length());
//   }

   void clear()
   {
      _body.clear();
   }

   SyntaxTree()
   {
   }
   SyntaxTree(_Memory* dump)
   {
      MemoryReader reader(dump);

      _body.load(&reader, reader.getDWord());
   }
};

//SyntaxTree::Node findSubNode(SyntaxTree::Node node, LexicalType type);
//SyntaxTree::Node findSubNode(SyntaxTree::Node node, LexicalType type1, LexicalType type2);
//SyntaxTree::Node findSubNodeMask(SyntaxTree::Node node, int mask);

typedef SyntaxTree::Writer       SyntaxWriter;
typedef SyntaxTree::Node         SNode;
//typedef SyntaxTree::NodePattern  SNodePattern;

} // _ELENA_

#endif // syntaxTreeH
