###
# Bezier curve
#@author Jean-Milost Reymond
##
class_name BezierCurve

extends RefCounted

###
# Calculates a point on a quadratic Bezier curve
#@param start - Bezier curve start coordinate
#@param end - Bezier curve end coordinate
#@param control - Bezier curve control point coordinate
#@param position - position of the point to find in percent (between 0.0f and 1.0f)
#@return quadratic Bezier point coordinate matching with position
##
static func get_quadratic_bezier_point(start, end, control, position):
	# point p0p1 is the point on the line formed by the start position and the control point, and
	# point p1p2 is the point on the line formed by the control point and the line end
	var p0p1 = get_point_on_line(start,   control, position)
	var p1p2 = get_point_on_line(control, end,     position)

	# the resulting point is the point found on the intermediate segment (p0p1 to p1p2)
	return get_point_on_line(p0p1, p1p2, position)

###
# Calculates a point on a cubic Bezier curve
#@param start - Bezier curve start coordinate
#@param end - Bezier curve end coordinate
#@param control1 - first Bezier curve control point coordinate
#@param control2 - second Bezier curve control point coordinate
#@param position - position of the point to find in percent (between 0.0f and 1.0f)
#@return cubic Bezier point coordinate matching with position
##
static func get_cubic_bezier_point(start, end, control1, control2, position):
	# point p0p1 is the point on the line formed by the start position and the first control point,
	# point p1p2 is the point on the line formed by the first control point and the second control
	# point, and point p2p3 is the point on the line formed by the second control point and the
	# line end
	var p0p1 = get_point_on_line(start,    control1, position)
	var p1p2 = get_point_on_line(control1, control2, position)
	var p2p3 = get_point_on_line(control2, end,      position)

	# the resulting point is the quadratic bezier point found on the intermediate segments (p0p1 to
	# p1p2 and p1p2 to p2p3)
	return get_quadratic_bezier_point(p0p1, p2p3, p1p2, position)

###
# Calculates a point on a line
#@param start - line start coordinate
#@param end - line end coordinate
#@param position - position of the point to find in percent (between 0.0f and 1.0f)
#@return point coordinates on the line
##
static func get_point_on_line(start, end, position):
	return (start + ((end - start) * position))
