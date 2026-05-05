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

    afterEvaluate {
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.let { android ->
            if (android.namespace.isNullOrEmpty()) {
                android.namespace = android.defaultConfig.applicationId
                    ?: project.group.toString()
            }
            // Force every plugin/module to JVM target 17 — works around old
            // packages (e.g. image_gallery_saver) that hard-code Java 1.8 while
            // the Kotlin compiler defaults to a newer version, causing the
            // "Inconsistent JVM-target compatibility" error.
            android.compileOptions.sourceCompatibility =
                org.gradle.api.JavaVersion.VERSION_17
            android.compileOptions.targetCompatibility =
                org.gradle.api.JavaVersion.VERSION_17
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()
            .configureEach {
                compilerOptions {
                    jvmTarget.set(
                        org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17,
                    )
                }
            }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
