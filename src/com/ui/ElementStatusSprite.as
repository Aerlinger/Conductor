package com.ui
{
	import com.element.*;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import spark.components.Label;

	public class ElementStatusSprite extends Sprite
	{
		private var mTypeText : TextField;
		private var mNameText : TextField;
		private var mPositionText : TextField;
		private var mBoundsText : TextField;
		private var mChildrenText : TextField;
		
		
		public function ElementStatusSprite()
		{
			mTypeText = new TextField();
			mTypeText.textColor = 0xFF0000;
			mTypeText.selectable = false;
			mTypeText.width = 500;
			
			mNameText = new TextField();
			mNameText.textColor = 0xDDCC00;
			mNameText.selectable = false;
			mNameText.width = 500;
			
			mPositionText = new TextField();
			mPositionText.textColor = 0xFF5511;
			mPositionText.selectable = false;
			mPositionText.width = 500;
			
			mBoundsText = new TextField();
			mBoundsText.textColor = 0x993344;
			mBoundsText.selectable = false;
			mBoundsText.width = 500;
			
			mChildrenText = new TextField();
			mChildrenText.textColor = 0xCC9966;
			mChildrenText.selectable = false;
			mChildrenText.width = 500;
			
			// initialize the text field
			reset();
			
			// Position each text field
			var vSpacing:Number = mNameText.textHeight;
			mTypeText.y = vSpacing;
			mPositionText.y = 2*vSpacing;
			mBoundsText.y = 3*vSpacing;
			mChildrenText.y = 4*vSpacing;
			
			
			addChild( mTypeText );
			addChild( mNameText );
			addChild( mPositionText );
			addChild( mBoundsText );
			addChild( mChildrenText );
			
		}
		
		private function reset() : void {
			mTypeText.text 		= "Type: ";
			mNameText.text 		= "Name: ";
			mPositionText.text 	= "Pos.: ";
			mBoundsText.text 	= "Bounds: ";
			mChildrenText.text 	= "Children: ";
		}
		
		public function setStatus( pElement:BaseElement ) : void {
			reset();
			
			setTypeText(pElement);
			setNameText(pElement.name, pElement);
			setPositionText(pElement.x, pElement.y, pElement.width, pElement.height);
			setBoundsText(pElement.getMinX(), pElement.getMinY(), pElement.getMinX()+pElement.width, pElement.getMinY()+pElement.height);
			setChildrenText(pElement.toString());
		}
		
		private function setTypeText( pType:BaseElement ) : void {
			mTypeText.text = "Type: ";
			
			if( pType is CircleElement )
				mTypeText.appendText("CircleElement");
			else if( pType is LineElement )
				mTypeText.appendText("LineElement");
			else if( pType is RectangleElement )
				mTypeText.appendText("RectangleElement");
			else if( pType is Group )
				mTypeText.appendText("Group");
			else
				mTypeText.appendText("BaseElement");
		}
		
		private function setNameText( pName:String, pType:BaseElement ) : void {
			mNameText.textColor = pType.getLabelColor();
			mNameText.text = "Name: " + pName;
		}
		
		private function setPositionText( x:Number, y:Number, width:Number, height:Number ) : void {
			mPositionText.text = "Pos.: (" + x + ", " + y + ")  [w: " + width + ", h: " + height + "]"; 
		}
		
		private function setBoundsText( xMin:Number, yMin:Number, xMax:Number, yMax:Number ) : void {
			mBoundsText.text = "Bounds: min(" + xMin + ", " + yMin + ") max(" + xMax + ", " + yMax + ")"; 
		}
		
		private function setChildrenText( pMessage:String ) : void {
			mChildrenText.text = "Children: " + pMessage;
		}
		
	}
}