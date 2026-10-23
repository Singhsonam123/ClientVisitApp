allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// SSL Certificate configuration for Gradle wrapper
tasks.register("configureSSL") {
    doFirst {
        System.setProperty("javax.net.ssl.trustStore", "")
        System.setProperty("javax.net.ssl.trustStorePassword", "")
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
