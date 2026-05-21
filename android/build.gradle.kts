allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://maven.google.com")
        }
        maven {
            url = uri("${rootProject.projectDir}/local_repo")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.google.android.ai.edge") {
                useVersion("0.1.0")
            }
        }
    }
    if (project.state.executed) {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.getByName("android")
            if (androidExt is com.android.build.gradle.LibraryExtension) {
                androidExt.compileSdk = 34
                androidExt.buildToolsVersion = "34.0.0"
            }
        }
    } else {
        afterEvaluate {
            if (project.hasProperty("android")) {
                val androidExt = project.extensions.getByName("android")
                if (androidExt is com.android.build.gradle.LibraryExtension) {
                    androidExt.compileSdk = 34
                    androidExt.buildToolsVersion = "34.0.0"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
