function isElementVisible(x0, y0, z0, x1, y1, z1, rotation, radius)
	rotation = math.rad(90 + rotation)
	
	local x2, y2 = rotatePosition(x1, y1, radius, 0, rotation)
	local x3, y3 = rotatePosition(x1, y1, -radius, 0, rotation)
	
	return isLineOfSightClear(x0, y0, z0, x2, y2, z1, true, false, false, false, false, true) or isLineOfSightClear(x0, y0, z0, x3, y3, z1, true, false, false, false, false, true)
end

function rotatePosition(x, y, cx, cy, angle)
	local cosinus, sinus = math.cos(angle), math.sin(angle)
	return x + (cx * cosinus - cy * sinus), y + (cx * sinus + cy * cosinus)
end