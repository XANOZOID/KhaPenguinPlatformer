package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Assets;
import engine.Hub;

class Main {
	static var hub:Hub;

	static function render(frames: Array<Framebuffer>): Void {
		hub.onDraw(frames[0].g2);
	}

	public static function main() {
		System.start({title: "Project", width: 1024, height: 768}, function (_) {
			Assets.loadEverything(function () {
				hub = new Hub();
				hub.onInit();
				hub.services.loader.load(
					Assets.blobs.Maps_map1_tmx.toString()
				);
				Scheduler.addTimeTask(function () { hub.onUpdate(); }, 0, 1 / 60);
				System.notifyOnFrames(function (frames) { render(frames); });
			});
		});
	}
}
