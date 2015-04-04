use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

pin_d = 6.7;
pin_depth = 21.5;
pin_ridge_elevation = 3;
pin_ridge_depth = 0.4;
pin_ridge_height = 3;

shaft_d = 6;
shaft_wall_thickness = 5;

wheel_d = 50;
wheel_clearance = 6;
wheel_cover_thickness = -epsilon;
wheel_cover_d = wheel_d + wheel_clearance + wheel_cover_thickness;
center_thickness = 14;

caster_width = 38;
hub_d = caster_width;
hub_height = wheel_cover_d / 2;
hub_extra_height = 5;
hub_min_width = 4;
shaft_offset = hub_d / 2;

$fs = 0.4;
$fa = 1;

module trapezoid (u, d, h)
{
    delta = d - u;

    polygon ([
            [0, 0],
            [d, 0],
            [d - delta / 2, h],
            [delta / 2, h]
        ]);
}

module round (r)
offset (r = r)
offset (r = -r)
children ();

module filleted_cylinder (d1, d2, h, fillet_r)
{
    rotate_extrude () {
        intersection () {
            round (-fillet_r)
            union () {
                intersection () {
                    translate ([-d1 / 2, 0])
                    trapezoid (d = d1, u = d2, h = h);

                    translate ([-500, 0])
                    square ([1000, 1000]);
                }

                mirror (Y)
                square ([1000, 1000]);
            }

            square ([1000, 1000]);
        }
    }
}

module caster ()
{
    elevation = shaft_wall_thickness + shaft_d / 2;

    translate ([0, 0, elevation])
    difference () {
        union () {
            hull () {
                rotate (90, X)
                cylinder (d = wheel_cover_d, h = caster_width, center = true);

                translate ([shaft_offset, 0, 0])
                cylinder (d = hub_d, h = hub_height);
            }

            // extra height for the hub
            translate ([shaft_offset, 0, hub_height - epsilon])
            filleted_cylinder (
                d1 = pin_d + hub_min_width * 4,
                d2 = pin_d + hub_min_width * 2,
                h = hub_extra_height,
                fillet_r = 5
            );
        }
        // cut off bottom
        translate ([0, 0, -wheel_cover_d - elevation])
        linear_extrude (height = wheel_cover_d)
        square ([1, 1] * wheel_cover_d * 2.5, center = true);

        // cut out wheels
        for (y = [1, -1] * (center_thickness / 2 + caster_width / 2))
        translate ([0, y])
        rotate (90, X)
        translate ([0, 0, -caster_width / 2])
        mcad_polyhole (
            d = wheel_d + wheel_clearance,
            h = caster_width
        );

        // pin
        translate ([shaft_offset, 0, hub_height - pin_depth])
        difference () {
            mcad_polyhole (d = pin_d + 0.3, h = wheel_d);

            rotate_extrude () {
                translate ([(pin_d + 0.3 + 0.2) / 2, pin_ridge_elevation])
                rotate (90, Z)
                trapezoid (u = pin_ridge_height - pin_ridge_depth * 2,
                    d = pin_ridge_height, h = pin_ridge_depth);
            }
        }

        // shaft
        rotate (90, X)
        translate ([0, 0, -caster_width / 2])
        mcad_polyhole (d = shaft_d + 0.3, h = caster_width);
    }
}

caster ();
