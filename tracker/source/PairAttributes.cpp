#include "PairAttributes.hpp"

#include <stdint.h>
#include "../../common/source/MyBool.hpp"
#include "../../common/source/macro.h"
#define NEW_PAIR_ATTRIBUTE(group, type, name, description, unit) attributeMap[STRINGIFY(name)] = new Attribute<type>(STRINGIFY(name), description, unit); group.push_back(STRINGIFY(name));

PairAttributes::PairAttributes() : AttributeCollection()
{
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, distanceBodyBody, "Distance between body centroids.", "px");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, distanceHeadBody, "Distance between this fly's head and the other fly's body centroids.", "px");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, distanceHeadTail, "Distance between this fly's head and the other fly's tail.", "px");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, changeInDistanceHeadBody, "Speed at which distanceHeadBody changes.", "px/frame");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, angleToOther, "Angle between the major axis and the line connecting the body centroids.", "deg");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, Vf2, vectorToOtherLocal, "Vector in this fly's local coordinate frame pointing to the other fly's body centroid.", "px");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, oriAngle, "Orientation angle criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, oriDistance, "Orientation distance criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, orienting, "This fly is orienting itself towards the other fly.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, rayEllipseOriHit, "This fly's viewing ray hits the other fly's body.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, rayEllipseOriAngle, "Orientation angle criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, rayEllipseOriDistance, "Orientation distance criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, rayEllipseOrienting, "This fly is orienting itself towards the other fly.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, follSmallChangeInDistance, "The changeInDistanceHeadBody attribute is below the threshold for following.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, follAngle, "Following angle criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, follDistance, "Following distance criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, follSameMovedDirection, "The flies move in roughly the same direction.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, follBehind, "[TODO: Come up with an intuitive description for this attribute.]", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, following, "This fly is following the other fly.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, followingOccurred, "Whether following has occurred in any frames up to and including this one.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, circAngle, "Circling angle criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, circDistance, "Circling distance criterion fulfilled.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, circling, "This fly is circling the other fly.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, wingExtTowards, "This fly is extending its wing towards the other fly.", "");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, MyBool, wingExtAway, "This fly is extending its wing away from the other fly.", "");

	// attributes resulting from unit conversion
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, distanceBodyBody_u, "Distance between body centroids.", "mm");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, distanceHeadBody_u, "Distance between this fly's head and the other fly's body centroids.", "mm");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, distanceHeadTail_u, "Distance between this fly's head and the other fly's tail.", "mm");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, float, changeInDistanceHeadBody_u, "Speed at which distanceHeadBody changes.", "mm/s");
	NEW_PAIR_ATTRIBUTE(derivedAttributes, Vf2, vectorToOtherLocal_u, "Vector in this fly's local coordinate frame pointing to the other fly's body centroid.", "mm");
}

void PairAttributes::clearDerivedAttributes()
{
	for (std::vector<std::string>::const_iterator iter = derivedAttributes.begin(); iter != derivedAttributes.end(); ++iter) {
		AbstractAttribute& attribute = get(*iter);
		attribute.clear();
	}
}