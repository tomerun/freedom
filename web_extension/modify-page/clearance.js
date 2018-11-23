const ngwords = ['ビチク', 'コビト', 'ﾋﾞﾁｸ', 'ｺﾋﾞﾄ', 'ユルアゴ']
const posts = document.querySelectorAll('div.post')
for (const post of posts) {
	const description = post.querySelector('div.message > span').innerText
	if (ngwords.some((ngword) => {
		return description.includes(ngword)
	})) {
		post.style.display = 'none'
	}
}