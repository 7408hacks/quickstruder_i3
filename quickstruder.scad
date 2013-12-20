/*parameters*/
// preview[view:south west, tilt:side]

/* [Global] */
//Part to generate
part="plate"; //["plate":All parts (print plate), "assembly":Assembled view (demonstrative only), "base":Base, "bracket":Extruder bracket plate, "idler":Idler]
//Filament diameter
filament=3.0; //[3.0, 1.75]
//Pulley type
pulley=1; //[0:"MK7",1:"MK8"]
//
version=0; //[0:right, 1:left]
//Generate additional support for nicer printing (still have to use normal support!)
support=1; //[1:Yes, 0:No]
//Generate brim - structure to get less warping when printing with ABS
brim=0; //[0:No, 1:Yes]

/* [Hidden] */
//Extruder type
extruder_type="j-head"; //["j-head"]

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
motor_wall_T=4;

hook_space=50;
hook_L=20;
hook_poly=[[-3,-3], [-3,3], [-5,3.5], [-5, 6], [1,6], [1,-3]];

mount_screw_D=4;
mount_screw_flange_D=9;
motor_screw_flange_L=25;
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
bracket_assembly_clearance=0.5;

idler_T=11;
idler_arm_L=motor_hole_spacing/2;
bearing_D=13;
bearing_L=5;
idler_assembled_angle=asin(((motor_hole_spacing-bearing_D-filament)/2-hotend_Y)/idler_arm_L);

support_T=0.4;
supported_angle=35;


$fn=40;
spring_pos=[-idler_T/2-motor_wall_T-.5,-motor_W/2+11,motor_W-2];

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
		linear_extrude(height=h, center=center)
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
				linear_extrude(height=50)
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
			linear_extrude(height=hook_L)
				polygon(hook_poly);
			//spring support
			translate([0,-motor_hole_spacing/2,(motor_W+motor_hole_spacing)/2])
			rotate([0,-90,0])
			linear_extrude(height=idler_T+0.5+motor_wall_T)
			union()
			{
				rotate([0,0,60])
				union()
				{
					for(i=[0,1])
					translate([0,-6*i,0])
						circle(r=5,$fn=50);
					translate([-10/2,-6,0])
						square([10,6]);
				}
				polygon([[-5,0], [-5,16], [-2,16], [10,-2]]);
			}
			if (brim)
			{
				translate([base_motor_L-support_T, -motor_W/2-10, -base_H-10])
					cube([support_T, 20, base_H+20]);
				for (i=[0,1])
					translate([base_motor_L-support_T, motor_W/2+side_wall_T-10, -base_H-10+(base_H+motor_W)*i])
						cube([support_T, 20, 20]);
			}
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
				cylinder(r=motor_flange_D/2+1, h=30, $fn=80);
		
		//motor screw holes
		for(i=[-1,1])
			for(k=[-1,1])
				translate([1, motor_hole_spacing/2*i, (motor_W+motor_hole_spacing*k)/2])
				rotate([0,-90,0])
				union()
				{
					translate([0,0,(1+support_T)*support])
						cylinder(r=motor_hole_D/2+.1, h=30, $fn=20);
					if(k==-1)
					translate([0,0,motor_wall_T])
						cylinder(r=7/2, h=30, $fn=40);
					if(i==-1 && k==1)
					translate([0,0,idler_T+0.5+motor_wall_T])
						cylinder(r=7/2, h=30, $fn=40);
					if(i==1 && k==-1)
					translate([0,-7/2,motor_wall_T])
						cube([7/2, 7, 30]);
				}
		//dziura na sprê¿ynê, dziura na œrubkê, ³o¿ysko
		//mount screw hole
		translate([base_motor_L-mount_screw_from_right,-motor_W/2-1,motor_W-mount_screw_from_top])
		rotate([-90,0,0])
		union()
		{
			supported_cylinder(r=mount_screw_D/2, h=motor_W+side_wall_T+2,z_rot=180,$fn=20);
			supported_cylinder(r=mount_screw_flange_D/2, h=motor_screw_flange_L+1,z_rot=180,$fn=40);
		}
		//bearing slot
		translate([-idler_T/2-motor_wall_T-.5, motor_hole_spacing/2, (motor_W+motor_hole_spacing)/2-idler_arm_L])
			rotate([0,90,0])
				cylinder(r=bearing_D/2+1, h=bearing_L+2, center=true);
		//spring hole
		translate(spring_pos)
			rotate([-30,0,0])
				supported_cylinder(r=4,h=3,z_rot=180);
	}
}

module hotend_bracket()
{
	difference()
	{
		//base
		translate([0,motor_W/2+side_wall_T-bracket_W,0])
		union()
		{
			difference()
			{
				cube([bracket_L,bracket_W,bracket_H]);
				if (part=="assembly")
				{
					translate([-1,-1,-1])
						cube([bracket_L+2, bracket_assembly_clearance+1, bracket_H+2]);
					translate([-1, -1, bracket_H-bracket_assembly_clearance])
						cube([bracket_L+2, bracket_W+2, 2]);
					translate([bracket_L-bracket_assembly_clearance, -1, -1])
						cube([2, bracket_W+2, bracket_H+2]);
				}
			}
			if (brim)
			for(i=[0,1])
				translate([0,bracket_W*i-10,-10])
					cube([support_T, 20, bracket_H+20]);
		}
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

module idler()
{
	$fn=40;
	difference()
	{
		
		linear_extrude(height=idler_T)
		union()
		{
			//base
			translate([0,-5.5,0])
				square([16.5,11]);
			for (i=[0,1])
				translate([16.5*i,0,0])
					circle(5.5);
			translate()
			rotate([0,0,120])
			//arm
			union()
			{
				square([35,5.5]);
				translate([35,5.5,0])
				union()
				{
					difference()
					{
						circle(5.5);
						translate([-8,0,0])
							square([16,8]);
					}
					rotate([0,0,30])
					scale([1,-1,1])
					union()
					{
						translate()
						square([7,5.5]);
						translate([7,5.5/2,0])
							circle(5.5/2);
					}
				}
			}
			polygon([[0,5.5], [-10,15], [-5,0]]);
		}
		//screw holes
		for (i=[0,1])
		translate([idler_arm_L*i,0,-1])
		union()
		{
			cylinder(r=3.1/2, h=13);
		}
		//bearing slot
		translate([idler_arm_L,0,-motor_wall_T-hotend_X-.5])
			cylinder(r=bearing_D/2+0.5, h=bearing_L+0.2, center=true);
		//filament slot
		translate([-14,9,-motor_wall_T-hotend_X-.5])
		rotate([90,0,90])
		linear_extrude(height=15)
		union()
		{
			for(i=[-1,1])
			translate([1.5*i,0,0])
				circle(r=3.6/2);
			square([3,3.6],center=true);
		}
		//spring hole
		rotate([0,-90,30])
			translate([idler_T/2,24,-1])
				cylinder(r=4,h=3);
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

//debug
section="no";

module generate()
{
intersection()
{
	union()
	{
		if (part=="assembly")
		{
				base();
				translate([base_motor_L-base_L,0,-base_H])
					hotend_bracket();
				translate([-motor_wall_T-.5,motor_hole_spacing/2,(motor_W+motor_hole_spacing)/2])
				rotate([-idler_assembled_angle,0,0])
				rotate([180,90,0])
				{
					idler();
					//bearing
					#translate([idler_arm_L,0,idler_T/2])
						cylinder(r=bearing_D/2,h=bearing_L,center=true);
					//washer
					#translate([0,0,-0.5])
						cylinder(r=7/2,h=.5,$fn=20);
				}
				translate([motor_L,0,motor_W/2])
				rotate([0,-90,0])
				#union()
				{
					NEMA17_motor();
					translate([0,0,motor_L-hotend_X+pulley_teeth_from_top-pulley_L])
						MK_pulley();
				}
				#hotend_base_translated();
				// filament
				#translate([hotend_X,hotend_Y,-5])
					cylinder(r=filament/2,h=55, $fn=20);
				//spring
				%translate(spring_pos)
					rotate([-30,0,0])
						cylinder(r=3.5,h=13);
		}
		if (part=="base" || part=="plate")
		{
			translate([0,0,base_motor_L])
				rotate([0,90,0])
					base();
		}
		if (part=="bracket" || part=="plate")
		{
			translate([80,0,0])
				rotate([0, -90, 0])
					hotend_bracket();
		}
		if (part=="idler" || part=="plate")
		{
			translate([40,-40,5.5])
				rotate([90,-54.8,0])
					idler();
		}
	}
	//debug
	if (section=="y")
	{
		translate([0,85,0])
			cube([150,150,200], center=true);
	}
	if (section=="x")
	{
		translate([65,0,0])
			cube([150,150,200], center=true);
	}
	if (section=="z")
	{
		translate([0,0,100+21])
			cube([150,150,200], center=true);
	}
}
}

if (version) // mirror
	scale([-1,1,1])
		generate();
else
	generate();




