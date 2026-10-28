# Project5-WebGPU-Gaussian-Splat-Viewer

**University of Pennsylvania, CIS 565: GPU Programming and Architecture, Project 5**

* Lilian Xiao
  * [LinkedIn](https://www.linkedin.com/in/lilian-xiao/), [personal website](https://lilianxiao.carrd.co/), [art website](https://lilianxvis.carrd.co/)
* Tested on: Windows 11, Intel(R) Core(TM) Ultra 9 185H (2.50 GHz), 16.0 GB RAM, NVIDIA GeForce RTX 4070 Laptop GPU (8 GB)
Intel(R) Arc(TM) Graphics (128 MB) (Personal Laptop)

## Live Demo

See the live Github page [here](https://lilianxiao.github.io/Project5-WebGPU-Gaussian-Splat-Viewer/).

## Demo Video/GIF

https://github.com/user-attachments/assets/418c49b5-0de3-41bd-891f-472ee80eef4d

https://github.com/user-attachments/assets/7db1050b-abda-46fe-8d1d-8d5e4662a2fa

https://github.com/user-attachments/assets/7be14465-1239-4ac4-9a1a-da4f62f08cc9

## OVERVIEW

Gaussian splatting (or 3DGS) is a method of volumetric rendering for the purposes of reconstructing photorealistic 3D scenes, using transparent colored ellipsoids (the gaussians or splats) instead of triangle meshes, as traditionally done.  These overlapping gaussians, when rendered together, form a composite that successfully recreates the scene from multiple different perspectives.

A gaussian stores data such as position, scale, opacity, color, and orientation.  Whereas a point cloud is a volume composed of points/vertices, a gaussian splat is like a cloud of these primitive volumes.  Since these gaussians are blended in real time and maintain depth information, the end result can be satisfactorily realistic.  As such, gaussian splatting is a promising and practical alternative to just traditionally rendering hard geometry.

## PERFORMANCE REVIEW

The .ply scene being used is bicycle_3000.cleaned.ply, which includes 1063091 gaussian splats, with default presets (unless otherwise tested).

### Point Cloud vs. Gaussian Renderer

<img width="1045" height="497" alt="image" src="https://github.com/user-attachments/assets/a3a5f824-483f-4fdf-b164-1187017bf658" />

<img width="2559" height="1375" alt="image" src="https://github.com/user-attachments/assets/e8d7e3f4-e6ca-4d0b-9d33-119aa9f64644" />

<img width="1057" height="500" alt="image" src="https://github.com/user-attachments/assets/09a4635b-207d-4052-ba91-236518fb951c" />

The point cloud is a very basic renderer, drawing each gaussian center as a simple point.  On the contrary, the complete Gaussian renderer constructs each gaussian with positional, color, opacity, spherical harmonics coeffs, and orientation information, then blends them with respect to depth.

Some differences: the point cloud doesn't really have a culling feature, but rasterization performs clipping.  Meanwhile, the Gaussian renderer explicitly constructs a viewing frustum and only sorts/draws visible gaussian splats.  The Gaussian renderer also performs back-to-front splat sorting for compositing alphas, but the point cloud has no such depth ordering, being all opaque.

<img width="600" height="364" alt="image" src="https://github.com/user-attachments/assets/eae7e309-e998-4c03-bf33-25d07dea7fa8" />

There are two undeniable sources of extra cost when it comes to the Gaussian renderer.  There is a cost associated with the radix sorting (4 passes, and keys are 32 bit), as well as a cost for filling the splats.  This actually grows quadratically with increasing gaussian multiplier, and becomes more noticeable as the resolution increases, or as the camera approaches larger gaussian splats.

<img width="602" height="368" alt="image" src="https://github.com/user-attachments/assets/4be17af1-d7b4-4d89-9256-216673cd2504" />

### Workgroup Size

<img width="602" height="370" alt="image" src="https://github.com/user-attachments/assets/a59cfa9a-b1e5-4a5d-ac42-011ed9b2d63a" />

Preliminary expectations are that very small sizes would be quite slow, due to warps having idle portions.  Though, since preprocessing is an independent thread per gaussian and no memory is shared, overall, large differences are not expected.  There is somewhat of a growing trend, but overall, a concrete conclusion on the "best" workgroup size cannot be formed.  Drops and increases between the ranges of 64 to 256 could be attributed to atomics and occupancy, since preprocessing requires many registers.

### Credits

- [Vite](https://vitejs.dev/)
- [tweakpane](https://tweakpane.github.io/docs//v3/monitor-bindings/)
- [stats.js](https://github.com/mrdoob/stats.js)
- [wgpu-matrix](https://github.com/greggman/wgpu-matrix)
- Special Thanks to: Shrek Shao (Google WebGPU team) & [Differential Guassian Renderer](https://github.com/graphdeco-inria/diff-gaussian-rasterization)
