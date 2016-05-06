import pygame
from pygame.locals import *

from OpenGL.GL import *
from OpenGL.GLU import *

verticies = (
    (1, -1, 0),
    (-1, -1, 0),
    (-1, 1, 0),
    (1, 1, 0)
    )

edges = (
    (0,1),
    (0,3),
    (2,1),
    (2,3)
    )


def Plane():
    glBegin(GL_LINES)
    for edge in edges:
        for vertex in edge:
            glVertex3fv(verticies[vertex])
    glEnd()

def Axis():
    glBegin(GL_LINES)

    glColor4ub(255, 0, 0, 255)
    glVertex3f(0.0, 0.0, 0.0)
    glVertex3f(1024.0, 0.0, 0.0)

    glColor4ub(0, 255, 0, 255)
    glVertex3f(0.0, 0.0, 0.0)
    glVertex3f(0.0, 1024.0, 0.0)

    glColor4ub(0, 0, 255, 255)
    glVertex3f(0.0, 0.0, 0.0)
    glVertex3f(0.0, 0.0, 1024.0)

    glColor4ub(255, 255, 255, 255)
    glEnd()

roll_angle = 0
yaw_angle = 90
pitch_angle = 0

def main():
    pygame.init()
    display = (800,600)
    pygame.display.set_mode(display, DOUBLEBUF|OPENGL)

    gluPerspective(45, (display[0]/display[1]), 0.1, 50.0)

    glTranslatef(0.0,0.0, -5)
    glRotatef(270, 0.0, 0.0, 1.0)
    glRotatef(-45.0, 0.0, 1.0, 0.0)
    glRotatef(-15.0, 0.0, 0.0, 1.0)


    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                quit()

#        glLoadIndentity()
#        glLoadMatrix(camera)
	glPushMatrix()
        glRotate(roll_angle, 0.0,0.0,1.0)
        glRotate(yaw_angle, 0.0,1.0,0.0)
        glRotate(pitch_angle, 1.0,0.0,0.0)
#        glTranslatef(strafe,jump,dir)
#        glGetFloatv(GL_MODELVIEW_MATRIX, camera)

#        glRotatef(1, 3, 1, 1)
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)
        Plane()

	glPopMatrix()

	Axis()

        pygame.display.flip()
        pygame.time.wait(10)


main()
