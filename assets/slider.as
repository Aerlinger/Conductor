package {
   import flash.display.Sprite;
   import flash.events.MouseEvent;

   public class slider extends Sprite {
      public function slider() {
         addEventListener(MouseEvent.MOUSE_DOWN, Down);
      }

      private function Down(e:MouseEvent):void {
         startDrag(false, this.parent.getBounds(this.parent));
         addEventListener(MouseEvent.MOUSE_UP, Up);
      }

      private function Up(e:MouseEvent):void {
         stopDrag();
         removeEventListener(MouseEvent.MOUSE_UP, Up);
      }
   }
}