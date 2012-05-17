package  {
	
	
	import flash.text.TextField;
	import mx.flash.UIMovieClip;
	
	
	public class TestComponent extends UIMovieClip {
		
		private var txtField:TextField = new TextField();
		private var txtField2:TextField = new TextField();
		
		public function TestComponent() {
			txtField.text = "TestText";
			txtField.height = 50;
		}
		
		public function loadFromTimeline(pTimeline) {
			this.width = 2*this.width;
		}
		
		[Inspectable(name="label", type= String, defaultValue= "TestText")]
      	public function set label(s:String):void {
         	txtField.text = s;
      	}

      	public function get label():String {
         	return txtField.text;
      	}
	}
	
}
