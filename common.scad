use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

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
{
    offset (r = r)
    offset (r = -r)
    children ();
}

module filleted_cylinder (d1, d2, h, fillet_r)
{
    rotate_extrude () {
        intersection () {
            round (-fillet_r)
            union () {
                // intersection () {
                    translate ([-d1 / 2, 0])
                    trapezoid (d = d1, u = d2, h = h);

                //     translate ([-500, 0])
                //     square ([1000, 1000]);
                // }

                mirror (Y)
                square ([1000, 1000]);
            }

            square ([1000, 1000]);
        }
    }
}

module ridged_hole (d, h, ridge_height, ridge_elevation, ridge_depth)
{
    difference () {
        mcad_polyhole (d = d, h = h);

        rotate_extrude () {
            translate ([d / 2 + 0.1, ridge_elevation])
            rotate (90, Z)
            trapezoid (u = ridge_height - ridge_depth * 2,
                d = ridge_height, h = ridge_depth);
        }
    }
}
