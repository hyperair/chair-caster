use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

use <common.scad>

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
hub_extra_height = 0;
hub_min_width = 4;
shaft_offset = hub_d / 2;

$fs = 0.4;
$fa = 1;

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
        translate ([shaft_offset, 0, hub_height + hub_extra_height - pin_depth])
        ridged_hole (
            d = pin_d + 0.3,
            h = wheel_d,
            ridge_height = pin_ridge_height,
            ridge_elevation = pin_ridge_elevation,
            ridge_depth = pin_ridge_depth
        );

        // shaft
        rotate (90, X)
        translate ([0, 0, -caster_width / 2])
        mcad_polyhole (d = shaft_d + 0.3, h = caster_width);
    }
}

caster ();
