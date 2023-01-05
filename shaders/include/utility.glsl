/*
utility

contains several useful utility functions
*/

float sqrt1(float x) { // x must in [0.0, 1.0]
    return x * (2.0 - x);
}

float length2(vec3 vec) {
    return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z;
}