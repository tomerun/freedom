"use strict";
(() => {
	const src = document.getElementById("src").getElementsByTagName("textarea")[0];
	const dst = document.getElementById("dst").getElementsByTagName("textarea")[0];
	const inputs = document.getElementById("convert").getElementsByTagName("input");

	function replace() {
		const src_text = src.value;
		let dst_text = "";
		for (let i = 0; i < src_text.length; i++) {
			const ch = src_text[i];
			if ("a" <= ch && ch <= "z") {
				const idx = src_text.charCodeAt(i) - 0x61;
				dst_text += inputs[idx].value;
			} else if ("A" <= ch && ch <= "Z") {
				const idx = src_text.charCodeAt(i) - 0x41;
				dst_text += inputs[idx].value.toUpperCase();
			} else {
				dst_text += ch;
			}
		}
		dst.value = dst_text;
	};

	src.addEventListener("change", (ev) => {
		replace();
	});

	for (const input of inputs) {
		input.addEventListener("change", (ev) => {
			replace();
		});
	}
})();