package com.element
{
	public final class ElementManager
	{
		
		private static var INSTANCE:ElementManager = null;
		
		private static var initialized:Boolean = false;
		
		private var ElementList:Vector.<BaseElement> 	= new Vector.<BaseElement>(); 
		private var GroupList:Vector.<Group> 			= new Vector.<Group>(); 
		
		
		
		public function ElementManager()
		{
			if(initialized) {
				Error("Only one instance of ElementManager can be created!");
			}
			initialized = true; // Prevent multiple instances of this class.
			
		}
		
		public static function getInstance() : ElementManager {
			if( INSTANCE == null ) {
				INSTANCE = new ElementManager();
			}
			
			return INSTANCE;
		}
		
		public function registerElement( pElement:BaseElement ) : uint {
			return ElementList.push(pElement);
		}
		
		public function unregisterElement( pElement:BaseElement ) : void {
			throw new Error("unregisterElement() not yet supported");
		}
		
		public function registerGroup( pElement:Group ) : uint {
			return GroupList.push(pElement);
		}
		
		public function unregisterGroup( pElement:Group )  : void {
			throw new Error("unregisterGroup() not yet supported");
		}
		
		public function getNumElements() : uint {
			return ElementList.length;
		}
		
		public function getNumGroups() : uint {
			return GroupList.length;
		}
		
		public function getTotal() : uint {
			return (getNumElements() + getNumGroups());
		}
		
	}
}