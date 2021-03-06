paper.install(window);

console.log([1,1] + [2,3])

var values = {
	paths: 1,
	minPoints: 5,
	maxPoints: 15,
	minRadius: 10,
	maxRadius: 30
};

var hitOptions = {
	segments: true,
	stroke: true,
	fill: true,
	tolerance: 5
};


window.createPaths = function() {
	var radiusDelta = values.maxRadius - values.minRadius;
	var pointsDelta = values.maxPoints - values.minPoints;
	for (var i = 0; i < values.paths; i++) {
		var radius = values.minRadius + Math.random() * radiusDelta;
		var points = values.minPoints + Math.floor(Math.random() * pointsDelta);
		var path = createBlob(new Point(view.size.width * Point.random().x, view.size.height * Point.random().y * 0.4), radius, points);
                
		var lightness = (Math.random() - 0.5) * 0.4 + 0.4;
		var hue = Math.random() * 360;
		path.fillColor = { hue: hue, saturation: 1, lightness: lightness };
		path.strokeColor = 'black';
	}
}

//window.createPaths();


function createBlob(center, maxRadius, points) {
	var path = new Path();
	path.closed = true;
	for (var i = 0; i < points; i++) {
		var delta = new Point({
			length: (maxRadius * 0.5) + (Math.random() * maxRadius * 0.5),
			angle: (360 / points) * i
		});
		path.add(center + delta);
	}
	path.smooth();
	return path;
}