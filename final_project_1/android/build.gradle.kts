buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google Services Gradle plugin
        // Removed because this project does not use Firebase. If you add Firebase later,
        // uncomment the line below and add a valid google-services.json to android/app/.
        // classpath("com.google.gms:google-services:4.4.0") // use latest stable
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
