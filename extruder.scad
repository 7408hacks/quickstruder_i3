/*parameters*/

/* [Global] */
//Extruder type
extruder_type="j-head"; //["j-head"]
//Filament diameter
filament=3.0; //[3.0, 1.75]
//Generate additional support for nicer printing (still have to use normal support!)
support=1; //[1:Yes, 0:No]
//Pulley type
pulley=0; //[0:"MK7",1:"MK8"]
//Part to generate
part="assemble"; //["plate":All parts (print plate), "assemble":Assembled view (demonstrative only) "base":Base, "arm":Arm, "bracket":Extruder bracket plate]

/* [Hidden] */
motor_W=42;
motor_L=40;
motor_shaft_D=5;
motor_shaft_L=23;
motor_flange_D=22;
motor_flange_L=2;
motor_connector_dim=[6,17,10];
motor_hole_spacing=31;
motor_hole_D=3;
motor_fillet_R=5;

pulley_D=12.6 - 4.7*pulley;
pulley_L=11;
pulley_drill_D=5.1;
pulley_effective_D=10.56 - 3.56*pulley;
pulley_teeth_R=3;
pulley_teeth_from_top=3.75;

jhead_rotate_poly=[[0,0], [8,0], [8,5], [6,5], [6,9.5], [8,9.5], [8,37], [3.85,41.15], [3.85,52], [0.65,53.6], [0,53.6]];
jhead_block_dim=[18.3, 14.9, 9.4];
jhead_block_move=[-12.1,-7.45,39.5];
hotend_D=16;

base_H=17;
base_L=52;
base_motor_L=30;
side_wall_T=5;
motor_wall_T=5;

hook_space=50;
hook_L=20;
hook_poly=[[-3,-3], [-3,3], [-5,3.5], [-5, 6], [1,6], [1,-3]];

mount_screw_D=4;
mount_screw_flange_D=9;
motor_scre_flange_L=25;
mount_screw_from_right=25;
mount_screw_from_top=50;

hotend_X=-10;
hotend_Y=pulley_effective_D/2+filament/2;
hotend_Z=-5;

filament_guide_D=15;
filament_guide_H=8.8;
filament_guide_chamfer=2;

bracket_W=40;
bracket_L=base_L-base_motor_L+hotend_X-hotend_D/4;
bracket_H=base_H+hotend_Z+2;
bracket_screw_D1=2.2;
bracket_screw_D2=3;
bracket_screw_D3=6;
bracket_screw_L=16;
bracket_screw_spacing=25;

support_T=0.4;
supported_angle=35;

module fillet(r, h, pos, rot)
{
	translate(pos)
	rotate(rot)
	translate([-r,-r,0])
		difference()
		{
			translate([0,0,-h/2])
				cube([r*2,r*2,h]);
			cylinder(r=r, h=h+2, center=true);
		}
}

sca=supported_angle;

module supported_cylinder(r=1,h=1,z_rot=0, center=false)
{
	union()
	{
		cylinder(r=r,h=h,center=center);
		if(support)
		rotate([0,0,z_rot])
		linear_extrude(h, center=center)
			polygon([[r*sin(sca),r*cos(sca)], [r, r*(cos(sca)-tan(sca)*(1-sin(sca)))], [r, -r*(cos(sca)-tan(sca)*(1-sin(sca)))],[r*sin(sca),-r*cos(sca)]]);
	}
}

module hotend_base(extr=0)
{
	if (extruder_type=="j-head")
	{
		rotate([0,180,0])
		union()
		{
			rotate_extrude(convexity = 50, $fn=50)
				polygon(jhead_rotate_poly);
			if (extr)
				for(i=[-1,1])
				scale([i,1,1])
				rotate([90,0,0])
				linear_extrude(50)
					polygon(jhead_rotate_poly);
			translate(jhead_block_move)
				cube(jhead_block_dim);
		}
	}
}

module hotend_base_translated(extr=0,rot=[0,0,0])
{
	translate([hotend_X,hotend_Y,hotend_Z])
	rotate(rot)
		hotend_base(extr);
}

module base()
{
	difference()
	{
		union()
		{
			//base
			translate([base_motor_L-base_L,-motor_W/2,-base_H])
				cube([base_L, motor_W+side_wall_T, base_H]);
			//motor wall
			translate([-motor_wall_T, -motor_W/2, -1])
				cube([motor_wall_T, motor_W+1, motor_W+1]);
			//side wall
			translate([base_motor_L-base_L, motor_W/2, -1])
				cube([base_L, side_wall_T, motor_W+1]);
			//filament guide
			translate([hotend_X,hotend_Y,-1])
			{
				cylinder(r=filament_guide_D/2,h=filament_guide_H+1, $fn=40);
				cylinder(r1=filament_guide_D/2+3.5,r2=0,h=filament_guide_D/2+3.5, $fn=40);
			}
			//quick mount hooks
			for (i=[0,-1])
			translate([(hook_space-hook_L)*i+base_motor_L,motor_W/2+side_wall_T,motor_W])
			rotate([0,-90,0])
			linear_extrude(hook_L)
				polygon(hook_poly);
		}
		//hotend_slot
		hotend_base_translated(extr=1,rot=[0,0,-90]);
		//hotend bracket slot
		translate([base_motor_L-base_L-1,motor_W/2+side_wall_T-bracket_W,-base_H-1])
			cube([bracket_L+1,bracket_W+1,bracket_H+1]);
		//screw holes - self tapping
		for(i=[-1,1])
			translate([base_motor_L-base_L,hotend_Y+bracket_screw_spacing/2*i,-base_H+bracket_H/2])
			rotate([0,90,0])
			cylinder(r=bracket_screw_D1/2,h=bracket_screw_L, $fn=20);
		//filament guide
		translate([hotend_X,hotend_Y,0])
		union()
		{
			supported_cylinder(r=filament/2+.2,h=50, center=true,z_rot=180, $fn=20);
			translate([0,0,filament_guide_H-filament_guide_chamfer-filament/2])
				cylinder(r1=0,r2=filament_guide_chamfer+filament/2+1,h=filament_guide_chamfer+filament/2+1,$fn=20);
		}
		//motor flange hole
		translate([1-(1+support_T)*support,0,motor_W/2])
			rotate([0,-90,0])
				cylinder(r=motor_flange_D/2+1, h=motor_wall_T+2, $fn=80);
		//motor screw holes
		for(i=[-1,1])
			for(k=[-1,1])
				translate([1, motor_hole_spacing/2*i, (motor_W+motor_hole_spacing*k)/2])
				rotate([0,-90,0])
				union()
				{
					translate([0,0,(1+support_T)*support])
						cylinder(r=motor_hole_D/2+.1, h=motor_wall_T+2, $fn=20);
					translate([0,0,motor_wall_T])
						cylinder(r=7/2, h=30, $fn=40);
				}
		translate([-motor_wall_T+1-30,motor_hole_spacing/2-7/2,(motor_W-motor_hole_spacing)/2])
			cube([30, 7, 7/2]);
		//mount screw hole
		translate([base_motor_L-mount_screw_from_right,-motor_W/2-1,motor_W-mount_screw_from_top])
		rotate([-90,0,0])
		union()
		{
			supported_cylinder(r=mount_screw_D/2, h=motor_W+motor_wall_T+2,z_rot=180,$fn=20);
			supported_cylinder(r=mount_screw_flange_D/2, h=motor_scre_flange_L+1,z_rot=180,$fn=40);
		}
		//motor wall fillet
		fillet(motor_fillet_R, motor_wall_T+2, [-motor_wall_T/2,-motor_W/2, motor_W], [180,-90,0], $fn=40);
	}
}

module hotend_bracket()
{
	difference()
	{
		//base
		translate([0,motor_W/2+side_wall_T-bracket_W,0])
			cube([bracket_L,bracket_W,bracket_H]);
		//screw holes
		for(i=[-1,1])
			translate([-1,hotend_Y+bracket_screw_spacing/2*i,bracket_H/2])
			rotate([0,90,0])
			union()
			{
				cylinder(r=bracket_screw_D2/2,h=bracket_L+2, $fn=20);
				cylinder(r=bracket_screw_D3/2,h=2, $fn=20);
				translate([0,0,1.95])
					cylinder(r1=bracket_screw_D3/2, r2=0, h=bracket_screw_D3/2, $fn=20);
			}
		//hotend_slot
		translate([bracket_L+hotend_D/4,hotend_Y,base_H+hotend_Z])
			hotend_base();

	}
}

module NEMA17_motor()
{
	translate([0,0,motor_L/2])
	union()
	{
		// base
		difference()
		{
			cube([motor_W,motor_W,motor_L], center=true);
			for(angle=[0:90:359])
			{
				rotate([0,0,angle])
					fillet(motor_fillet_R,motor_L+2,[motor_W/2,motor_W/2,0],[0,0,0], $fn=50);
			}
		}
		//flange
		cylinder(r=motor_flange_D/2,h=motor_L/2+motor_flange_L, $fn=50);
		//shaft
		cylinder(r=motor_shaft_D/2,h=motor_L/2+motor_flange_L+motor_shaft_L, $fn=50);
		//connector
		translate([0,-motor_connector_dim[1]/2,-motor_L/2])
			cube([motor_connector_dim[0]+motor_W/2,motor_connector_dim[1],motor_connector_dim[2]]);
	}
}

module MK_pulley()
{
	union()
	{
		difference()
		{
			cylinder(r=pulley_D/2, h=pulley_L, $fn=50);
			cylinder(r=pulley_drill_D/2, h=pulley_L*3, center=true, $fn=50);
			rotate_extrude(convexity = 50)
			translate([pulley_effective_D/2+pulley_teeth_R,pulley_L-pulley_teeth_from_top,0])
				circle(r=pulley_teeth_R, $fn=20);
		}
		//screw
		translate([pulley_D/2,0,2.5])
			rotate([0,90,0])
				cylinder(r=1.5,h=2, center=true,$fn=20);
	}
}


section="no";

intersection()
{
	union()
	{
		if (part=="assemble")
		{
				base();
				translate([base_motor_L-base_L,0,-base_H])
					hotend_bracket();
				translate([motor_L,0,motor_W/2])
				rotate([0,-90,0])
				#union()
				{
					NEMA17_motor();
					translate([0,0,motor_L-hotend_X+pulley_teeth_from_top-pulley_L])
						MK_pulley();
				}
				*hotend_base_translated();
				// filament
				#translate([hotend_X,hotend_Y,-5])
					cylinder(r=filament/2,h=55, $fn=6);
		}
		if (part=="base" || part=="plate")
		{
			translate([0,0,base_motor_L])
				rotate([0,90,0])
					base();
		}
		if (part=="bracket" || part=="plate")
		{
			translate()
				rotate()
					hotend_bracket();
		}
	}
	if (section=="y")
	{
		translate([0,60,0])
		cube([100,100,100], center=true);
	}
}




