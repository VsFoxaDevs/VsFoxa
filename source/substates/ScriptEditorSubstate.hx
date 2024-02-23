package substates;

import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.FlxSubState;

class ScriptEditorSubstate extends FlxSubState
{
	var sample = 'function onCreate()\n\nend';
	var _file:FileReference;
	var app:HaxeUIApp;
	var WM:WindowManager;
	var mainView:Window;
	var container:VBox;
	var btnContainer:HBox;
	var codeEdit:TextArea;
	var savebtn:Button;
	var closebtn:Button;

	public function new()
	{
		super(FlxColor.fromRGB(0, 0, 0, 160));
		Toolkit.init();
	}

	override public function create()
	{
		super.create();
		app = new HaxeUIApp();
		app.ready(() ->
		{
			WM = new WindowManager();
			// var mainView:Component = ComponentBuilder.fromFile("assets/data/main-view.xml");
			mainView = new Window();
			mainView.title = "Editor";
			mainView.left = 20;
			mainView.top = 20;

			container = new VBox();
			container.width = 856;
			container.height = 480;
			codeEdit = new TextArea();
			codeEdit.width = 856;
			codeEdit.height = 480;
			codeEdit.styleString = "font-size: 18px";
			codeEdit.text = sample;
			container.addComponent(codeEdit);

			btnContainer = new HBox();
			savebtn = new Button();
			savebtn.text = "Save";
			savebtn.onClick = (MouseEvent) ->
			{
				_file = new FileReference();
				_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
				_file.addEventListener(Event.CANCEL, onSaveCancel);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				_file.save(codeEdit.text, "script.lua");
			};
			closebtn = new Button();
			closebtn.text = "Close";
			closebtn.onClick = (MouseEvent) ->
			{
				WM.closeWindow(mainView);
				app.removeComponent(mainView, true);
				FlxG.mouse.useSystemCursor = false;
				this.close();
			}

			btnContainer.addComponent(savebtn);
			btnContainer.addComponent(closebtn);

			mainView.addComponent(container);
			mainView.addComponent(btnContainer);

			WM.addWindow(mainView);

			// mainView.set_x(300);
			// mainView.set_y(300);

			app.addComponent(mainView);
			app.start();
		});
		FlxG.mouse.useSystemCursor = true;
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LUA script data.");
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving LUA script data");
	}
}