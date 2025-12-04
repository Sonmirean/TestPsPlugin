cmake_minimum_required (VERSION 3.8)

if (POLICY CMP0141)
  cmake_policy(SET CMP0141 NEW)
  set(
	  CMAKE_MSVC_DEBUG_INFORMATION_FORMAT 
	  "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>"
  )
endif()

project ("TestPsPlugin")

add_executable (TestPsPlugin "src/test_automation_main.cpp")

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET TestPsPlugin PROPERTY CXX_STANDARD 20)
endif()

target_include_directories(TestPsPlugin PRIVATE "include/")

set(PSSDK_INCLUDE_PATH "C:/C libraries/psapi")

# Headers path for Ps SDK
target_include_directories(
	TestPsPlugin 
	PUBLIC 
	"${PSSDK_INCLUDE_PATH}/photoshop"
	"${PSSDK_INCLUDE_PATH}/ai"
	"${PSSDK_INCLUDE_PATH}/common"
	"${PSSDK_INCLUDE_PATH}/common/includes"
	"${PSSDK_INCLUDE_PATH}/common/resources"
	"${PSSDK_INCLUDE_PATH}/common/sources"
	"${PSSDK_INCLUDE_PATH}/pica_sp"
	"${PSSDK_INCLUDE_PATH}/resources"
)

