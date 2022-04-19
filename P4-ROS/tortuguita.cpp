#include "turtlesim/Pose.h"
#include "ros/ros.h"
#include "geometry_msgs/Twist.h"

#include <iostream>
#include <sstream>
#include <fstream>
#include <array>
#include <string>
using namespace std;


/** Variables globales **/
ros::Publisher vel_pub;
ros::Subscriber pose_sub;
int const NUMERO_DATOS = 6;
typedef array<double, NUMERO_DATOS> arrayDatos;

/** Funciones **/
void poseCallback(const turtlesim::Pose::ConstPtr& msg);
void move(double speed, double distance, bool isForward);
void rotate(double angular_vel, double relative_angle, bool clockWise);
arrayDatos procesarEntrada(string fila);


int main(int argc, char **argv)
{
  ros::init(argc, argv, "pr4");
  ros::NodeHandle n;

  /** Utilizamos el mismo fichero para publicar y suscribir **/
  vel_pub = n.advertise<geometry_msgs::Twist>("/turtle1/cmd_vel", 1000);
  pose_sub = n.subscribe("turtlesim", 1000, poseCallback);

  /** Lectura del fichero **/
  /** Ej de linea de fichero: 2 2 0 0 0 1.8; **/  
  ifstream indata("/home/viki/catkin_ws/src/tortuguita/datos.txt");
  string fila;
  arrayDatos valores;
  
  /** Abrimos el fichero **/
  if(indata.is_open())
  {
	/** Mientras haya lineas por leer... **/
	while(getline(indata, fila))
	{
		/** ... obtenemos los datos **/
		valores = procesarEntrada(fila);
		if(valores[0] != 0.0)
			move(valores[0], 1, true);
		if(valores[5] != 0.0)
			rotate(valores[5], 1, true);
		/** Hacemos que ROSS procese el callback **/	
		ros::spinOnce();
	}
  }
  else
  {
	cout << "Error al abrir el fichero." << endl;
  }
  ros::shutdown();
  return 0; 
}


/** Muestra la posicion de la tortuga **/
void poseCallback(const turtlesim::Pose::ConstPtr& msg) 
{
  ROS_INFO("Position of turtle: x:[%f] y:[%f] theta:[%f] linVel:[%f] angVel:[%f]", msg->x, msg->y, msg->theta, msg->linear_velocity, msg->angular_velocity);
}

/** Metodo para mover el robot en linea recta **/
void move(double speed, double distance, bool isForward) 
{
	geometry_msgs::Twist vel_msg;
	
	// linear velocity
	if (isForward)
		vel_msg.linear.x = abs(speed);
	else
		vel_msg.linear.x = -abs(speed);
	vel_msg.linear.y = 0;
	vel_msg.linear.z = 0;
	// angular velocity
	vel_msg.angular.x = 0;
	vel_msg.angular.y = 0;
	vel_msg.angular.z = 0;

	double t0 = ros::Time::now().toSec();
	double distancia_actual = 0.0;
	ros::Rate loop_rate(10);
	
	do{
		vel_pub.publish(vel_msg);
		double t1 = ros::Time::now().toSec();
		/** Def fisica --> dist = vel * tiempo **/
		distancia_actual = speed * (t1-t0);
		ros::spinOnce();
		loop_rate.sleep();
	}while(distancia_actual < distance);
	
	vel_msg.linear.x = 0;
	vel_pub.publish(vel_msg);
}

/** Metodo para rotar el robot **/
void rotate(double angular_vel, double relative_angle, bool clockWise)
{
	geometry_msgs::Twist vel_msg;

	vel_msg.linear.x = 0;
        vel_msg.linear.y = 0;
        vel_msg.linear.z = 0;

        vel_msg.angular.x = 0;
        vel_msg.angular.y = 0;

        if(clockWise)
                vel_msg.angular.z = -abs(angular_vel);
        else
                vel_msg.angular.z = abs(angular_vel);
        
	double angulo_actual = 0.0;
        double t0 = ros::Time::now().toSec();
        ros::Rate loop_rate(10);

        do{
                vel_pub.publish(vel_msg);
                double t1 = ros::Time::now().toSec();
                angulo_actual = angular_vel * (t1-t0);
                ros::spinOnce();
                loop_rate.sleep();
        }while(angulo_actual < relative_angle);

        vel_msg.angular.z = 0;
        vel_pub.publish(vel_msg);
}

arrayDatos procesarEntrada(string fila) 
{
	size_t pos = 0;
	arrayDatos datos;
	string valor;
	string delimitador = " ";
	int cont = 0;
	
	while((pos = fila.find(delimitador)) != string::npos)
	{
		valor = fila.substr(0,pos);
		datos[cont] = stod(valor);
		fila.erase(0, pos+1);
		cont++;
	}
	datos[cont] = stod(fila.substr(0,fila.length()-1));
	return datos;
}


